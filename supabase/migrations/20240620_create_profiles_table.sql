-- Crear la tabla de perfiles si no existe
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Eliminar políticas existentes si hay
DROP POLICY IF EXISTS "Permitir lectura pública de perfiles" ON profiles;
DROP POLICY IF EXISTS "Permitir inserción de perfiles" ON profiles;
DROP POLICY IF EXISTS "Permitir actualización de perfiles" ON profiles;
DROP POLICY IF EXISTS "Permitir todas las operaciones" ON profiles;

-- Crear políticas de seguridad para la tabla profiles
-- Permitir lectura pública
CREATE POLICY "Permitir lectura pública de perfiles" 
  ON public.profiles FOR SELECT 
  USING (true);

-- Permitir inserción para cualquier usuario (anónimo o autenticado)
CREATE POLICY "Permitir inserción de perfiles" 
  ON public.profiles FOR INSERT 
  WITH CHECK (true);

-- Permitir actualización para cualquier usuario (anónimo o autenticado)
CREATE POLICY "Permitir actualización de perfiles" 
  ON public.profiles FOR UPDATE 
  USING (true);

-- Habilitar RLS en la tabla profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Crear trigger para actualizar el campo updated_at automáticamente
DROP FUNCTION IF EXISTS update_profiles_updated_at() CASCADE;

CREATE OR REPLACE FUNCTION update_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION update_profiles_updated_at(); 