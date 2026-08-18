-- ============================================================================
-- FASE 2: RPCs DE PEDIDOS Y REALTIME - TILARÁN EN LÍNEA
-- ============================================================================
-- Toda mutación de pedidos pasa por estas funciones SECURITY DEFINER:
--  * create_order: crea el pedido con precios calculados EN EL SERVIDOR
--    (el cliente solo manda product_id + cantidad; nunca precios).
--  * advance_order_status: valida la máquina de estados según el rol.
--  * claim_order: asignación atómica del repartidor (dos repartidores no
--    pueden tomar el mismo pedido).
-- Ejecutar DESPUÉS de 03_roles_and_marketplace_schema.sql
-- ============================================================================

-- ============================================================================
-- 1. create_order
-- ============================================================================
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
  IF NOT v_store.is_open THEN
    RAISE EXCEPTION 'La tienda está cerrada en este momento';
  END IF;

  IF p_delivery_method = 'delivery' THEN
    v_delivery_fee := v_store.delivery_fee;
    IF p_address_detail IS NULL OR length(trim(p_address_detail)) = 0 THEN
      RAISE EXCEPTION 'La dirección de entrega es obligatoria';
    END IF;
  END IF;

  -- Subtotal con precios del servidor (snapshot; nunca del cliente)
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

REVOKE EXECUTE ON FUNCTION public.create_order(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, NUMERIC, TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_order(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, NUMERIC, TEXT, JSONB) TO authenticated;

-- ============================================================================
-- 2. advance_order_status — máquina de estados validada por rol
-- ============================================================================
CREATE OR REPLACE FUNCTION public.advance_order_status(
  p_order_id UUID,
  p_new_status TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_order public.orders%ROWTYPE;
  v_is_owner BOOLEAN;
  v_allowed BOOLEAN := false;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'No autenticado';
  END IF;

  SELECT * INTO v_order FROM public.orders WHERE id = p_order_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'El pedido no existe';
  END IF;

  v_is_owner := EXISTS (
    SELECT 1 FROM public.stores s
    WHERE s.id = v_order.store_id AND s.owner_id = v_uid
  );

  -- Cliente: puede cancelar mientras el negocio no haya aceptado
  IF v_order.customer_id = v_uid
     AND v_order.status = 'pending'
     AND p_new_status = 'cancelled' THEN
    v_allowed := true;
  END IF;

  -- Negocio dueño: acepta/rechaza/prepara/lista; entrega directa si es pickup
  IF v_is_owner AND (
       (v_order.status = 'pending' AND p_new_status IN ('accepted', 'rejected'))
    OR (v_order.status = 'accepted' AND p_new_status = 'preparing')
    OR (v_order.status = 'preparing' AND p_new_status = 'ready')
    OR (v_order.status = 'ready' AND p_new_status = 'delivered'
        AND v_order.delivery_method = 'pickup')
  ) THEN
    v_allowed := true;
  END IF;

  -- Repartidor asignado: recoge y entrega
  IF v_order.driver_id = v_uid AND (
       (v_order.status = 'ready' AND p_new_status = 'picked_up')
    OR (v_order.status = 'picked_up' AND p_new_status = 'delivered')
  ) THEN
    v_allowed := true;
  END IF;

  IF NOT v_allowed THEN
    RAISE EXCEPTION 'Transición no permitida: % → %', v_order.status, p_new_status;
  END IF;

  UPDATE public.orders SET status = p_new_status WHERE id = p_order_id;

  INSERT INTO public.order_status_history (order_id, status, changed_by)
  VALUES (p_order_id, p_new_status, v_uid);
END;
$$;

REVOKE EXECUTE ON FUNCTION public.advance_order_status(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.advance_order_status(UUID, TEXT) TO authenticated;

-- ============================================================================
-- 3. claim_order — asignación atómica del repartidor
-- ============================================================================
CREATE OR REPLACE FUNCTION public.claim_order(p_order_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'No autenticado';
  END IF;
  IF (SELECT role FROM public.profiles WHERE id = v_uid) <> 'driver' THEN
    RAISE EXCEPTION 'Solo un repartidor puede tomar pedidos';
  END IF;

  -- UPDATE condicional: si otro repartidor lo tomó primero, FOUND es false
  UPDATE public.orders
  SET driver_id = v_uid
  WHERE id = p_order_id
    AND status = 'ready'
    AND driver_id IS NULL
    AND delivery_method = 'delivery';

  RETURN FOUND;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.claim_order(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.claim_order(UUID) TO authenticated;

-- ============================================================================
-- 4. Realtime en orders (para el tracking en vivo)
-- ============================================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'orders'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
  END IF;
END $$;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
