-- Crear la tabla de perfiles si no existe
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Crear políticas de seguridad para la tabla profiles
-- Permitir lectura pública
CREATE POLICY "Permitir lectura pública de perfiles" 
  ON public.profiles FOR SELECT 
  USING (true);

-- Permitir inserción solo al propietario del perfil o si es anónimo
CREATE POLICY "Permitir inserción de perfiles" 
  ON public.profiles FOR INSERT 
  WITH CHECK (auth.uid() = id OR auth.role() = 'anon');

-- Permitir actualización solo al propietario del perfil o si es anónimo
CREATE POLICY "Permitir actualización de perfiles" 
  ON public.profiles FOR UPDATE 
  USING (auth.uid() = id OR auth.role() = 'anon');

-- Habilitar RLS en la tabla profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Crear trigger para actualizar el campo updated_at automáticamente
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