-- ============================================================================
-- DIRECCIONES RICAS + PAGOS SINPE CON COMPROBANTE - TILARÁN EN LÍNEA
-- ============================================================================
-- 1) addresses: distrito y punto de referencia (estilo Uber/DiDi) además de
--    las señas y el pin exacto (latitude/longitude ya existían).
-- 2) stores.sinpe_number: a qué SINPE Móvil le cae el dinero al negocio.
-- 3) orders: estado del pago + comprobante. Flujo SINPE:
--    pending → (cliente sube comprobante) submitted → (negocio verifica
--    contra su cuenta) verified | rejected. El negocio NO puede aceptar un
--    pedido SINPE sin verificar el pago (advance_order_status lo bloquea).
-- 4) Bucket PRIVADO payment-proofs: solo cliente dueño, negocio y admin.
-- ============================================================================

ALTER TABLE public.addresses
  ADD COLUMN IF NOT EXISTS district TEXT,
  ADD COLUMN IF NOT EXISTS reference TEXT;

ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS sinpe_number TEXT;

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS payment_status TEXT NOT NULL DEFAULT 'not_required'
    CHECK (payment_status IN
      ('not_required', 'pending', 'submitted', 'verified', 'rejected')),
  ADD COLUMN IF NOT EXISTS payment_reference TEXT,
  ADD COLUMN IF NOT EXISTS payment_proof_path TEXT;

-- ── create_order: los pedidos SINPE nacen con pago 'pending' ────────────────
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
  IF p_payment_method = 'sinpe'
     AND (v_store.sinpe_number IS NULL OR v_store.sinpe_number = '') THEN
    RAISE EXCEPTION 'Esta tienda no acepta SINPE Móvil todavía';
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
    payment_status, address_label, address_detail, latitude, longitude,
    subtotal, delivery_fee, total, notes
  ) VALUES (
    v_order_id, v_customer, p_store_id, 'pending', p_delivery_method,
    p_payment_method,
    CASE WHEN p_payment_method = 'sinpe' THEN 'pending' ELSE 'not_required' END,
    p_address_label, p_address_detail, p_latitude, p_longitude,
    v_subtotal, v_delivery_fee, v_subtotal + v_delivery_fee, p_notes
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

-- ── El cliente sube su comprobante (permite re-subir si fue rechazado) ──────
CREATE OR REPLACE FUNCTION public.submit_payment_proof(
  p_order_id UUID,
  p_proof_path TEXT,
  p_reference TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order public.orders%ROWTYPE;
BEGIN
  SELECT * INTO v_order FROM public.orders
  WHERE id = p_order_id FOR UPDATE;
  IF NOT FOUND OR v_order.customer_id <> auth.uid() THEN
    RAISE EXCEPTION 'El pedido no existe';
  END IF;
  IF v_order.payment_method <> 'sinpe' THEN
    RAISE EXCEPTION 'Este pedido no se paga por SINPE Móvil';
  END IF;
  IF v_order.payment_status NOT IN ('pending', 'submitted', 'rejected') THEN
    RAISE EXCEPTION 'El pago ya fue verificado';
  END IF;
  IF v_order.status IN ('delivered', 'rejected', 'cancelled') THEN
    RAISE EXCEPTION 'El pedido ya finalizó';
  END IF;

  UPDATE public.orders
  SET payment_status = 'submitted',
      payment_proof_path = p_proof_path,
      payment_reference = p_reference
  WHERE id = p_order_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.submit_payment_proof(UUID, TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.submit_payment_proof(UUID, TEXT, TEXT) TO authenticated;

-- ── El negocio verifica el comprobante contra su cuenta SINPE ───────────────
CREATE OR REPLACE FUNCTION public.review_sinpe_payment(
  p_order_id UUID,
  p_approved BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order public.orders%ROWTYPE;
BEGIN
  SELECT * INTO v_order FROM public.orders
  WHERE id = p_order_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'El pedido no existe';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.stores s
    WHERE s.id = v_order.store_id AND s.owner_id = auth.uid()
  ) AND public.current_user_role() <> 'admin' THEN
    RAISE EXCEPTION 'Solo el negocio o un admin puede revisar el pago';
  END IF;
  IF v_order.payment_status <> 'submitted' THEN
    RAISE EXCEPTION 'No hay comprobante pendiente de revisión';
  END IF;

  UPDATE public.orders
  SET payment_status = CASE WHEN p_approved THEN 'verified' ELSE 'rejected' END
  WHERE id = p_order_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.review_sinpe_payment(UUID, BOOLEAN) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.review_sinpe_payment(UUID, BOOLEAN) TO authenticated;

-- ── advance_order_status: no aceptar pedidos SINPE sin pago verificado ──────
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

  IF v_order.customer_id = v_uid
     AND v_order.status = 'pending'
     AND p_new_status = 'cancelled' THEN
    v_allowed := true;
  END IF;

  IF v_is_owner AND (
       (v_order.status = 'pending' AND p_new_status IN ('accepted', 'rejected'))
    OR (v_order.status = 'accepted' AND p_new_status = 'preparing')
    OR (v_order.status = 'preparing' AND p_new_status = 'ready')
    OR (v_order.status = 'ready' AND p_new_status = 'delivered'
        AND v_order.delivery_method = 'pickup')
  ) THEN
    v_allowed := true;
  END IF;

  -- Un pedido SINPE solo se acepta con el pago verificado
  IF v_is_owner AND v_order.status = 'pending' AND p_new_status = 'accepted'
     AND v_order.payment_method = 'sinpe'
     AND v_order.payment_status <> 'verified' THEN
    RAISE EXCEPTION 'Verifica el pago SINPE antes de aceptar el pedido';
  END IF;

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

-- ── Bucket PRIVADO para comprobantes (ruta: <order_id>/<archivo>) ───────────
INSERT INTO storage.buckets (id, name, public)
VALUES ('payment-proofs', 'payment-proofs', false)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS payment_proofs_insert_customer ON storage.objects;
CREATE POLICY payment_proofs_insert_customer ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'payment-proofs'
    AND EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id::text = (storage.foldername(name))[1]
        AND o.customer_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS payment_proofs_read_parties ON storage.objects;
CREATE POLICY payment_proofs_read_parties ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'payment-proofs'
    AND EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id::text = (storage.foldername(name))[1]
        AND (
          o.customer_id = auth.uid()
          OR public.is_store_owner(o.store_id)
          OR public.current_user_role() = 'admin'
        )
    )
  );

NOTIFY pgrst, 'reload schema';
