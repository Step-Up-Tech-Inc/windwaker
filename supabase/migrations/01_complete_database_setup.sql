-- ============================================================================
-- CONFIGURACIÓN COMPLETA DE BASE DE DATOS - TILARÁN EN LÍNEA
-- ============================================================================
-- Este script crea todas las tablas, funciones, triggers y políticas necesarias
-- Ejecutar PRIMERO antes de seed_stores_and_products.sql
-- ============================================================================

-- Habilitar extensión UUID si no está habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLA: profiles
-- Almacena información de perfil de usuarios
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY,
  email TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- TABLA: stores
-- Almacena información de las tiendas/negocios
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL,
  category TEXT NOT NULL,
  rating NUMERIC(3,1) NOT NULL DEFAULT 0.0,
  delivery_time_minutes INTEGER NOT NULL DEFAULT 30,
  delivery_fee NUMERIC(5,2) NOT NULL DEFAULT 0.00,
  is_open BOOLEAN NOT NULL DEFAULT true,
  is_featured BOOLEAN NOT NULL DEFAULT false,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- TABLA: products
-- Almacena los productos de cada tienda
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL,
  category TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  unit TEXT NOT NULL DEFAULT 'unidad',
  quantity NUMERIC(10,2) NOT NULL DEFAULT 1.0,
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  status INTEGER NOT NULL DEFAULT 0,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- TABLA: inventory
-- Control de inventario de productos
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.inventory (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  quantity NUMERIC(10,2) NOT NULL DEFAULT 0,
  min_quantity NUMERIC(10,2) NOT NULL DEFAULT 5,
  max_quantity NUMERIC(10,2) NOT NULL DEFAULT 100,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(product_id)
);

-- ============================================================================
-- ÍNDICES para mejorar rendimiento
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_stores_category ON public.stores(category);
CREATE INDEX IF NOT EXISTS idx_stores_is_deleted ON public.stores(is_deleted);
CREATE INDEX IF NOT EXISTS idx_stores_is_featured ON public.stores(is_featured);
CREATE INDEX IF NOT EXISTS idx_products_store_id ON public.products(store_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category);
CREATE INDEX IF NOT EXISTS idx_products_is_deleted ON public.products(is_deleted);
CREATE INDEX IF NOT EXISTS idx_inventory_product_id ON public.inventory(product_id);

-- ============================================================================
-- FUNCIONES Y TRIGGERS
-- ============================================================================

-- Función para actualizar updated_at en profiles
CREATE OR REPLACE FUNCTION public.update_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar updated_at en stores
CREATE OR REPLACE FUNCTION public.update_stores_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar updated_at en products
CREATE OR REPLACE FUNCTION public.update_products_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar updated_at en inventory
CREATE OR REPLACE FUNCTION public.update_inventory_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
DROP TRIGGER IF EXISTS on_profile_update_set_timestamp ON public.profiles;
CREATE TRIGGER on_profile_update_set_timestamp
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_profiles_updated_at();

DROP TRIGGER IF EXISTS on_store_update_set_timestamp ON public.stores;
CREATE TRIGGER on_store_update_set_timestamp
  BEFORE UPDATE ON public.stores
  FOR EACH ROW
  EXECUTE FUNCTION public.update_stores_updated_at();

DROP TRIGGER IF EXISTS on_product_update_set_timestamp ON public.products;
CREATE TRIGGER on_product_update_set_timestamp
  BEFORE UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION public.update_products_updated_at();

DROP TRIGGER IF EXISTS on_inventory_update_set_timestamp ON public.inventory;
CREATE TRIGGER on_inventory_update_set_timestamp
  BEFORE UPDATE ON public.inventory
  FOR EACH ROW
  EXECUTE FUNCTION public.update_inventory_updated_at();

-- ============================================================================
-- FUNCIÓN: search_stores
-- Búsqueda de tiendas por nombre, descripción o categoría
-- ============================================================================
CREATE OR REPLACE FUNCTION public.search_stores(search_query TEXT)
RETURNS SETOF public.stores AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.stores
  WHERE
    is_deleted = false
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

-- ============================================================================
-- FUNCIÓN: upsert_profile
-- Insertar o actualizar perfil de usuario
-- ============================================================================
CREATE OR REPLACE FUNCTION public.upsert_profile(
  user_id UUID,
  user_email TEXT,
  user_phone TEXT
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO public.profiles (id, email, phone)
  VALUES (user_id, user_email, user_phone)
  ON CONFLICT (id)
  DO UPDATE SET
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    updated_at = now();
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas antiguas si existen
DROP POLICY IF EXISTS "Permitir acceso de lectura a todos" ON public.profiles;
DROP POLICY IF EXISTS "Permitir a los usuarios insertar su propio perfil" ON public.profiles;
DROP POLICY IF EXISTS "Permitir a los usuarios actualizar su propio perfil" ON public.profiles;
DROP POLICY IF EXISTS "Permitir a los usuarios borrar su propio perfil" ON public.profiles;
DROP POLICY IF EXISTS "Permitir lectura a todos" ON public.stores;
DROP POLICY IF EXISTS "Permitir lectura a todos" ON public.products;
DROP POLICY IF EXISTS "Permitir lectura a todos" ON public.inventory;

-- Políticas para profiles
CREATE POLICY "Permitir acceso de lectura a todos"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Permitir a los usuarios insertar su propio perfil"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Permitir a los usuarios actualizar su propio perfil"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Permitir a los usuarios borrar su propio perfil"
  ON public.profiles FOR DELETE
  USING (auth.uid() = id);

-- Políticas para stores (lectura pública)
CREATE POLICY "Permitir lectura a todos"
  ON public.stores FOR SELECT
  USING (true);

-- Políticas para products (lectura pública)
CREATE POLICY "Permitir lectura a todos"
  ON public.products FOR SELECT
  USING (true);

-- Políticas para inventory (lectura pública)
CREATE POLICY "Permitir lectura a todos"
  ON public.inventory FOR SELECT
  USING (true);

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
