-- Fix marketplace schema
-- El problema se debe a que antes se intentaba acceder a "public.marketplace.products"
-- Lo correcto es "marketplace.products"

-- Verificamos que el esquema existe
CREATE SCHEMA IF NOT EXISTS marketplace;

-- Creamos la tabla stores si no existe, ya que se hace referencia a ella pero puede no existir
CREATE TABLE IF NOT EXISTS marketplace.stores (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    owner_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- Verificamos que las tablas existen
CREATE TABLE IF NOT EXISTS marketplace.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    category TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    unit TEXT NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    store_id UUID NOT NULL,
    status SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS marketplace.inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID NOT NULL,
    product_id UUID NOT NULL REFERENCES marketplace.products(id),
    current_stock DECIMAL(10, 2) NOT NULL,
    min_stock DECIMAL(10, 2) NOT NULL,
    max_stock DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- Desactivamos RLS temporalmente para permitir la carga de datos
ALTER TABLE IF EXISTS marketplace.products DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS marketplace.inventory DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS marketplace.stores DISABLE ROW LEVEL SECURITY;

-- Función update_updated_at sin DO block
CREATE OR REPLACE FUNCTION marketplace.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creamos triggers solo si no existen (sin verificación)
DROP TRIGGER IF EXISTS set_products_updated_at ON marketplace.products;
CREATE TRIGGER set_products_updated_at
BEFORE UPDATE ON marketplace.products
FOR EACH ROW
EXECUTE FUNCTION marketplace.update_updated_at();

DROP TRIGGER IF EXISTS set_inventory_updated_at ON marketplace.inventory;
CREATE TRIGGER set_inventory_updated_at
BEFORE UPDATE ON marketplace.inventory
FOR EACH ROW
EXECUTE FUNCTION marketplace.update_updated_at();

-- Creamos políticas básicas de RLS
-- Solo permitimos SELECT para todos y dejamos los demás permisos para más adelante
ALTER TABLE marketplace.products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS products_select_policy ON marketplace.products;
CREATE POLICY products_select_policy ON marketplace.products 
    FOR SELECT 
    USING (NOT is_deleted);

ALTER TABLE marketplace.inventory ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS inventory_select_policy ON marketplace.inventory;
CREATE POLICY inventory_select_policy ON marketplace.inventory 
    FOR SELECT 
    USING (NOT is_deleted);

ALTER TABLE marketplace.stores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS stores_select_policy ON marketplace.stores;
CREATE POLICY stores_select_policy ON marketplace.stores 
    FOR SELECT 
    USING (NOT is_deleted);

-- Función de utilidad para verificar si una tabla existe
CREATE OR REPLACE FUNCTION public.check_table_exists(table_name text)
RETURNS boolean AS $$
DECLARE
    result boolean;
BEGIN
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema || '.' || table_name = $1
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 