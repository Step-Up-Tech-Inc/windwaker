-- ============================================================================
-- FASE 6: APROBACIÓN DE TIENDAS - TILARÁN EN LÍNEA
-- ============================================================================
-- Las tiendas nuevas quedan 'pending' hasta que un admin las apruebe.
-- Mientras tanto: no aparecen para los clientes (RLS + search_stores) y no
-- pueden recibir pedidos (create_order las rechaza).
-- ============================================================================

ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected'));

-- Las tiendas existentes (creadas antes de este flujo) quedan aprobadas
UPDATE public.stores SET status = 'approved' WHERE status = 'pending';

-- Lectura: los clientes solo ven tiendas aprobadas; el dueño ve la suya
-- siempre; el admin ve todas.
DROP POLICY IF EXISTS "Permitir lectura a todos" ON public.stores;
DROP POLICY IF EXISTS stores_select_visible ON public.stores;
CREATE POLICY stores_select_visible ON public.stores
  FOR SELECT USING (
    status = 'approved'
    OR owner_id = auth.uid()
    OR public.current_user_role() = 'admin'
  );

-- El admin puede actualizar cualquier tienda (aprobar/rechazar)
DROP POLICY IF EXISTS stores_update_admin ON public.stores;
CREATE POLICY stores_update_admin ON public.stores
  FOR UPDATE USING (public.current_user_role() = 'admin')
  WITH CHECK (public.current_user_role() = 'admin');

-- search_stores: solo tiendas aprobadas
CREATE OR REPLACE FUNCTION public.search_stores(search_query TEXT)
RETURNS SETOF public.stores AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.stores
  WHERE
    is_deleted = false
    AND status = 'approved'
    AND (
      name ILIKE '%' || search_query || '%'
      OR description ILIKE '%' || search_query || '%'
      OR category ILIKE '%' || search_query || '%'
    )
  ORDER BY
    CASE WHEN name ILIKE '%' || search_query || '%' THEN 0 ELSE 1 END,
    CASE WHEN category ILIKE '%' || search_query || '%' THEN 0 ELSE 1 END,
    CASE WHEN description ILIKE '%' || search_query || '%' THEN 0 ELSE 1 END,
    name;
END;
$$ LANGUAGE plpgsql;

-- create_order: rechazar pedidos a tiendas no aprobadas (se agrega la
-- validación tras cargar la tienda)
CREATE OR REPLACE FUNCTION public.create_order(
  p_store_id UUID,
  p_delivery_method TEXT,
  p_payment_method TEXT,
  p_address_label TEXT,
  p_address_detail TEXT,
  p_latitude NUMERIC,
  p_longitude NUMERIC,
  p_notes TEXT,
  p_items JSONB
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_customer UUID := auth.uid();
  v_store public.stores%ROWTYPE;
  v_product public.products%ROWTYPE;
  v_item JSONB;
  v_order_id UUID;
  v_qty INTEGER;
  v_subtotal NUMERIC(10,2) := 0;
  v_delivery_fee NUMERIC(10,2) := 0;
BEGIN
  IF v_customer IS NULL THEN
    RAISE EXCEPTION 'No autenticado';
  END IF;
  IF p_delivery_method NOT IN ('delivery', 'pickup') THEN
    RAISE EXCEPTION 'Método de entrega inválido';
  END IF;
  IF p_payment_method NOT IN ('cash', 'sinpe') THEN
    RAISE EXCEPTION 'Método de pago inválido';
  END IF;
  IF p_items IS NULL OR jsonb_typeof(p_items) <> 'array'
     OR jsonb_array_length(p_items) = 0 THEN
    RAISE EXCEPTION 'El pedido no tiene productos';
  END IF;

  SELECT * INTO v_store FROM public.stores
  WHERE id = p_store_id AND is_deleted = false;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'La tienda no existe';
  END IF;
  IF v_store.status <> 'approved' THEN
    RAISE EXCEPTION 'La tienda aún no está aprobada para vender';
  END IF;
  IF NOT v_store.is_open THEN
    RAISE EXCEPTION 'La tienda está cerrada en este momento';
  END IF;

  IF p_delivery_method = 'delivery' THEN
    v_delivery_fee := v_store.delivery_fee;
    IF p_address_detail IS NULL OR length(trim(p_address_detail)) = 0 THEN
      RAISE EXCEPTION 'La dirección de entrega es obligatoria';
    END IF;
  END IF;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_qty := COALESCE((v_item->>'quantity')::INTEGER, 0);
    IF v_qty <= 0 THEN
      RAISE EXCEPTION 'Cantidad inválida en el pedido';
    END IF;
    SELECT * INTO v_product FROM public.products
    WHERE id = (v_item->>'product_id')::UUID
      AND store_id = p_store_id
      AND is_deleted = false;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Producto no disponible: %', v_item->>'product_id';
    END IF;
    v_subtotal := v_subtotal + (v_product.price * v_qty);
  END LOOP;

  v_order_id := uuid_generate_v4();

  INSERT INTO public.orders (
    id, customer_id, store_id, status, delivery_method, payment_method,
    address_label, address_detail, latitude, longitude,
    subtotal, delivery_fee, total, notes
  ) VALUES (
    v_order_id, v_customer, p_store_id, 'pending', p_delivery_method,
    p_payment_method, p_address_label, p_address_detail, p_latitude,
    p_longitude, v_subtotal, v_delivery_fee, v_subtotal + v_delivery_fee,
    p_notes
  );

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    SELECT * INTO v_product FROM public.products
    WHERE id = (v_item->>'product_id')::UUID;
    INSERT INTO public.order_items (
      order_id, product_id, product_name, unit_price, quantity, notes
    ) VALUES (
      v_order_id, v_product.id, v_product.name, v_product.price,
      (v_item->>'quantity')::INTEGER, v_item->>'notes'
    );
  END LOOP;

  INSERT INTO public.order_status_history (order_id, status, changed_by)
  VALUES (v_order_id, 'pending', v_customer);

  RETURN v_order_id;
END;
$$;

NOTIFY pgrst, 'reload schema';
