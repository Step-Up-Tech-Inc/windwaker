-- Esta migración mueve las tablas del esquema marketplace al esquema público
-- para solucionar el problema de acceso que causa el error:
-- "relation "public.marketplace.products" does not exist"

-- Primero verificamos si existen las tablas en el esquema marketplace
DO $$
DECLARE
    products_exists BOOLEAN;
    inventory_exists BOOLEAN;
    stores_exists BOOLEAN;
BEGIN
    -- Verificar si existen las tablas en el esquema marketplace
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'marketplace' AND table_name = 'products'
    ) INTO products_exists;
    
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'marketplace' AND table_name = 'inventory'
    ) INTO inventory_exists;
    
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'marketplace' AND table_name = 'stores'
    ) INTO stores_exists;
    
    -- Si existen las tablas, creamos tablas equivalentes en el esquema public
    IF products_exists THEN
        -- Crear tabla products en el esquema public
        CREATE TABLE IF NOT EXISTS public.products (
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
        
        -- Copiar datos de marketplace.products a public.products
        INSERT INTO public.products
        SELECT * FROM marketplace.products
        ON CONFLICT (id) DO NOTHING;
        
        RAISE NOTICE 'Tabla products creada y datos copiados';
    END IF;
    
    IF inventory_exists THEN
        -- Crear tabla inventory en el esquema public
        CREATE TABLE IF NOT EXISTS public.inventory (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            store_id UUID NOT NULL,
            product_id UUID NOT NULL REFERENCES public.products(id),
            current_stock DECIMAL(10, 2) NOT NULL,
            min_stock DECIMAL(10, 2) NOT NULL,
            max_stock DECIMAL(10, 2) NOT NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            is_deleted BOOLEAN NOT NULL DEFAULT FALSE
        );
        
        -- Copiar datos de marketplace.inventory a public.inventory
        INSERT INTO public.inventory
        SELECT * FROM marketplace.inventory
        ON CONFLICT (id) DO NOTHING;
        
        RAISE NOTICE 'Tabla inventory creada y datos copiados';
    END IF;
    
    IF stores_exists THEN
        -- Crear tabla stores en el esquema public
        CREATE TABLE IF NOT EXISTS public.stores (
            id UUID PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            owner_id UUID,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            is_deleted BOOLEAN NOT NULL DEFAULT FALSE
        );
        
        -- Copiar datos de marketplace.stores a public.stores
        INSERT INTO public.stores
        SELECT * FROM marketplace.stores
        ON CONFLICT (id) DO NOTHING;
        
        RAISE NOTICE 'Tabla stores creada y datos copiados';
    END IF;

    -- Si no existen las tablas en el esquema marketplace, las creamos en el esquema public
    IF NOT products_exists THEN
        -- Crear tabla products en el esquema public
        CREATE TABLE IF NOT EXISTS public.products (
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
        
        RAISE NOTICE 'Tabla products creada en el esquema public';
    END IF;
    
    IF NOT inventory_exists THEN
        -- Crear tabla inventory en el esquema public
        CREATE TABLE IF NOT EXISTS public.inventory (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            store_id UUID NOT NULL,
            product_id UUID NOT NULL REFERENCES public.products(id),
            current_stock DECIMAL(10, 2) NOT NULL,
            min_stock DECIMAL(10, 2) NOT NULL,
            max_stock DECIMAL(10, 2) NOT NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            is_deleted BOOLEAN NOT NULL DEFAULT FALSE
        );
        
        RAISE NOTICE 'Tabla inventory creada en el esquema public';
    END IF;
    
    IF NOT stores_exists THEN
        -- Crear tabla stores en el esquema public
        CREATE TABLE IF NOT EXISTS public.stores (
            id UUID PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            owner_id UUID,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            is_deleted BOOLEAN NOT NULL DEFAULT FALSE
        );
        
        RAISE NOTICE 'Tabla stores creada en el esquema public';
    END IF;
END $$;

-- Crear función para actualizar updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear triggers para las tablas
DROP TRIGGER IF EXISTS set_products_updated_at ON public.products;
CREATE TRIGGER set_products_updated_at
BEFORE UPDATE ON public.products
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS set_inventory_updated_at ON public.inventory;
CREATE TRIGGER set_inventory_updated_at
BEFORE UPDATE ON public.inventory
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS set_stores_updated_at ON public.stores;
CREATE TRIGGER set_stores_updated_at
BEFORE UPDATE ON public.stores
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at();

-- Habilitar RLS en las tablas
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;

-- Crear políticas para las tablas
DROP POLICY IF EXISTS products_select_policy ON public.products;
CREATE POLICY products_select_policy ON public.products
    FOR SELECT
    USING (NOT is_deleted);

DROP POLICY IF EXISTS inventory_select_policy ON public.inventory;
CREATE POLICY inventory_select_policy ON public.inventory
    FOR SELECT
    USING (NOT is_deleted);

DROP POLICY IF EXISTS stores_select_policy ON public.stores;
CREATE POLICY stores_select_policy ON public.stores
    FOR SELECT
    USING (NOT is_deleted); 