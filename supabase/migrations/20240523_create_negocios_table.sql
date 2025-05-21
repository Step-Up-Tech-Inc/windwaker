-- Crear la tabla de negocios
CREATE TABLE IF NOT EXISTS public.negocios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    imagen_url TEXT NOT NULL,
    calificacion NUMERIC(3, 1) NOT NULL CHECK (calificacion >= 1 AND calificacion <= 5),
    tiempo_entrega_min INTEGER NOT NULL CHECK (tiempo_entrega_min > 0),
    tiempo_entrega_max INTEGER NOT NULL CHECK (tiempo_entrega_max > tiempo_entrega_min),
    costo_envio NUMERIC(10, 2) NOT NULL CHECK (costo_envio >= 0),
    categoria TEXT NOT NULL,
    ciudad TEXT NOT NULL,
    es_destacado BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_negocios_ciudad ON public.negocios(ciudad);
CREATE INDEX IF NOT EXISTS idx_negocios_categoria ON public.negocios(categoria);
CREATE INDEX IF NOT EXISTS idx_negocios_activo ON public.negocios(activo);
CREATE INDEX IF NOT EXISTS idx_negocios_destacado ON public.negocios(es_destacado);

-- Función para actualizar el timestamp de updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar el timestamp de updated_at
CREATE TRIGGER update_negocios_updated_at
BEFORE UPDATE ON public.negocios
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Insertar datos de ejemplo
INSERT INTO public.negocios (nombre, imagen_url, calificacion, tiempo_entrega_min, tiempo_entrega_max, costo_envio, categoria, ciudad, es_destacado, activo)
VALUES 
    ('Restaurante El Buen Sabor', 'https://picsum.photos/200/300', 4.5, 25, 35, 1500, 'Restaurante', 'Tilarán', TRUE, TRUE),
    ('Supermercado La Esquina', 'https://picsum.photos/200/300', 4.2, 15, 25, 1200, 'Supermercado', 'Tilarán', TRUE, TRUE);

-- Configurar permisos (RLS - Row Level Security)
ALTER TABLE public.negocios ENABLE ROW LEVEL SECURITY;

-- Política para permitir lectura a todos los usuarios
CREATE POLICY "Permitir lectura pública de negocios activos" 
    ON public.negocios 
    FOR SELECT 
    USING (activo = TRUE);

-- Política para permitir inserción/actualización solo a usuarios autenticados con rol específico
-- Nota: Esto se implementaría cuando se tenga el sistema de autenticación y roles
-- CREATE POLICY "Permitir inserción/actualización solo a administradores" 
--     ON public.negocios 
--     FOR ALL 
--     USING (auth.role() = 'admin');