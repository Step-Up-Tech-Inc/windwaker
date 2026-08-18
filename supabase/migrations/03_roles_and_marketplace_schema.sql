-- ============================================================================
-- FASE 1: ROLES Y ESQUEMA DE MARKETPLACE - TILARÁN EN LÍNEA
-- ============================================================================
-- Agrega roles de usuario, dueños de tienda y el esquema de pedidos.
-- Ejecutar DESPUÉS de 01_complete_database_setup.sql
--
-- Decisiones de diseño:
--  * orders NO tiene política de UPDATE: toda transición de estado se hará
--    vía funciones RPC SECURITY DEFINER que validan la máquina de estados
--    (se agregan en la migración de Fase 2). Seguro por defecto.
--  * order_items guarda snapshot de nombre y precio: el historial no cambia
--    aunque el negocio edite su menú.
-- ============================================================================

-- ============================================================================
-- 1. PROFILES: rol y datos personales
-- ============================================================================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'customer'
    CHECK (role IN ('customer', 'business', 'driver', 'admin')),
  ADD COLUMN IF NOT EXISTS full_name TEXT,
  ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- ============================================================================
-- 2. STORES: dueño, ubicación y contacto
-- ============================================================================
ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES public.profiles(id),
  ADD COLUMN IF NOT EXISTS address TEXT,
  ADD COLUMN IF NOT EXISTS latitude NUMERIC(10,7),
  ADD COLUMN IF NOT EXISTS longitude NUMERIC(10,7),
  ADD COLUMN IF NOT EXISTS phone TEXT,
  ADD COLUMN IF NOT EXISTS schedule JSONB;

CREATE INDEX IF NOT EXISTS idx_stores_owner_id ON public.stores(owner_id);

-- ============================================================================
-- 3. TABLA: addresses — direcciones de entrega del cliente
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.addresses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  detail TEXT NOT NULL,
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON public.addresses(user_id);

-- ============================================================================
-- 4. TABLA: orders — pedidos
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID NOT NULL REFERENCES public.profiles(id),
  store_id UUID NOT NULL REFERENCES public.stores(id),
  driver_id UUID REFERENCES public.profiles(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending',    -- creado, esperando que el negocio acepte
    'accepted',   -- negocio aceptó
    'preparing',  -- en preparación
    'ready',      -- listo para recoger (visible a repartidores)
    'picked_up',  -- repartidor lo recogió / en camino
    'delivered',  -- entregado
    'rejected',   -- negocio rechazó
    'cancelled'   -- cliente canceló (solo en pending)
  )),
  delivery_method TEXT NOT NULL DEFAULT 'delivery'
    CHECK (delivery_method IN ('delivery', 'pickup')),
  payment_method TEXT NOT NULL DEFAULT 'cash'
    CHECK (payment_method IN ('cash', 'sinpe')),
  -- Snapshot de la dirección al momento del pedido
  address_label TEXT,
  address_detail TEXT,
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
  delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (delivery_fee >= 0),
  total NUMERIC(10,2) NOT NULL CHECK (total >= 0),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON public.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_store_id ON public.orders(store_id);
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON public.orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);

-- ============================================================================
-- 5. TABLA: order_items — líneas del pedido (snapshot de nombre y precio)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id),
  product_name TEXT NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);

-- ============================================================================
-- 6. TABLA: order_status_history — línea de tiempo auditable del pedido
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.order_status_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  changed_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id
  ON public.order_status_history(order_id);

-- ============================================================================
-- 7. TABLA: reviews — una reseña por pedido entregado
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL UNIQUE REFERENCES public.orders(id),
  store_id UUID NOT NULL REFERENCES public.stores(id),
  customer_id UUID NOT NULL REFERENCES public.profiles(id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reviews_store_id ON public.reviews(store_id);

-- ============================================================================
-- 8. FUNCIONES AUXILIARES
-- ============================================================================

-- Trigger genérico de updated_at (reemplaza a las funciones por-tabla)
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_order_update_set_timestamp ON public.orders;
CREATE TRIGGER on_order_update_set_timestamp
  BEFORE UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- Rol del usuario autenticado (SECURITY DEFINER: evita recursión de RLS si
-- en el futuro se restringe la lectura de profiles)
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

REVOKE EXECUTE ON FUNCTION public.current_user_role() FROM anon;
GRANT EXECUTE ON FUNCTION public.current_user_role() TO authenticated;

-- ¿El usuario autenticado es dueño de la tienda?
CREATE OR REPLACE FUNCTION public.is_store_owner(p_store_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.stores s
    WHERE s.id = p_store_id AND s.owner_id = auth.uid()
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_store_owner(UUID) FROM anon;
GRANT EXECUTE ON FUNCTION public.is_store_owner(UUID) TO authenticated;

-- ============================================================================
-- 9. ROW LEVEL SECURITY
-- ============================================================================
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- ── addresses: CRUD solo del propio usuario ─────────────────────────────────
DROP POLICY IF EXISTS addresses_select_own ON public.addresses;
CREATE POLICY addresses_select_own ON public.addresses
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS addresses_insert_own ON public.addresses;
CREATE POLICY addresses_insert_own ON public.addresses
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS addresses_update_own ON public.addresses;
CREATE POLICY addresses_update_own ON public.addresses
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS addresses_delete_own ON public.addresses;
CREATE POLICY addresses_delete_own ON public.addresses
  FOR DELETE USING (user_id = auth.uid());

-- ── orders: los ve el cliente, el negocio dueño, el repartidor asignado,
--    y los repartidores ven pedidos 'ready' sin asignar ──────────────────────
DROP POLICY IF EXISTS orders_select_participants ON public.orders;
CREATE POLICY orders_select_participants ON public.orders
  FOR SELECT USING (
    customer_id = auth.uid()
    OR driver_id = auth.uid()
    OR public.is_store_owner(store_id)
    OR (
      status = 'ready'
      AND driver_id IS NULL
      AND public.current_user_role() = 'driver'
    )
  );

-- El cliente crea su propio pedido, siempre en estado 'pending' y sin repartidor
DROP POLICY IF EXISTS orders_insert_own ON public.orders;
CREATE POLICY orders_insert_own ON public.orders
  FOR INSERT WITH CHECK (
    customer_id = auth.uid()
    AND status = 'pending'
    AND driver_id IS NULL
  );

-- Sin política de UPDATE/DELETE: transiciones solo vía RPC (Fase 2).

-- ── order_items: visibles/insertables según el pedido padre ─────────────────
DROP POLICY IF EXISTS order_items_select_participants ON public.order_items;
CREATE POLICY order_items_select_participants ON public.order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id
        AND (
          o.customer_id = auth.uid()
          OR o.driver_id = auth.uid()
          OR public.is_store_owner(o.store_id)
        )
    )
  );

DROP POLICY IF EXISTS order_items_insert_own ON public.order_items;
CREATE POLICY order_items_insert_own ON public.order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id
        AND o.customer_id = auth.uid()
        AND o.status = 'pending'
    )
  );

-- ── order_status_history: misma visibilidad que el pedido; solo lectura
--    (las escrituras llegan por los RPC SECURITY DEFINER de Fase 2) ──────────
DROP POLICY IF EXISTS order_status_history_select_participants
  ON public.order_status_history;
CREATE POLICY order_status_history_select_participants
  ON public.order_status_history
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id
        AND (
          o.customer_id = auth.uid()
          OR o.driver_id = auth.uid()
          OR public.is_store_owner(o.store_id)
        )
    )
  );

-- ── reviews: lectura pública; escribe solo el cliente de un pedido entregado ─
DROP POLICY IF EXISTS reviews_select_all ON public.reviews;
CREATE POLICY reviews_select_all ON public.reviews
  FOR SELECT USING (true);

DROP POLICY IF EXISTS reviews_insert_own ON public.reviews;
CREATE POLICY reviews_insert_own ON public.reviews
  FOR INSERT WITH CHECK (
    customer_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id
        AND o.customer_id = auth.uid()
        AND o.store_id = reviews.store_id
        AND o.status = 'delivered'
    )
  );

-- ── stores: escribe solo el dueño (rol business o admin) ────────────────────
DROP POLICY IF EXISTS stores_insert_owner ON public.stores;
CREATE POLICY stores_insert_owner ON public.stores
  FOR INSERT WITH CHECK (
    owner_id = auth.uid()
    AND public.current_user_role() IN ('business', 'admin')
  );

DROP POLICY IF EXISTS stores_update_owner ON public.stores;
CREATE POLICY stores_update_owner ON public.stores
  FOR UPDATE USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());

-- ── products: escribe solo el dueño de la tienda ────────────────────────────
DROP POLICY IF EXISTS products_insert_owner ON public.products;
CREATE POLICY products_insert_owner ON public.products
  FOR INSERT WITH CHECK (public.is_store_owner(store_id));

DROP POLICY IF EXISTS products_update_owner ON public.products;
CREATE POLICY products_update_owner ON public.products
  FOR UPDATE USING (public.is_store_owner(store_id))
  WITH CHECK (public.is_store_owner(store_id));

DROP POLICY IF EXISTS products_delete_owner ON public.products;
CREATE POLICY products_delete_owner ON public.products
  FOR DELETE USING (public.is_store_owner(store_id));

-- ── inventory: escribe solo el dueño de la tienda (vía producto) ────────────
DROP POLICY IF EXISTS inventory_insert_owner ON public.inventory;
CREATE POLICY inventory_insert_owner ON public.inventory
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.products p
      WHERE p.id = product_id AND public.is_store_owner(p.store_id)
    )
  );

DROP POLICY IF EXISTS inventory_update_owner ON public.inventory;
CREATE POLICY inventory_update_owner ON public.inventory
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.products p
      WHERE p.id = product_id AND public.is_store_owner(p.store_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.products p
      WHERE p.id = product_id AND public.is_store_owner(p.store_id)
    )
  );

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
