-- Función para crear la tabla de perfiles si no existe
CREATE OR REPLACE FUNCTION create_profiles_table()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Crear la tabla si no existe
  CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
  );

  -- Crear políticas de seguridad para la tabla profiles
  -- Permitir lectura pública
  BEGIN
    CREATE POLICY "Permitir lectura pública de perfiles" 
      ON public.profiles FOR SELECT 
      USING (true);
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;

  -- Permitir inserción solo al propietario del perfil o si es anónimo
  BEGIN
    CREATE POLICY "Permitir inserción de perfiles" 
      ON public.profiles FOR INSERT 
      WITH CHECK (auth.uid() = id OR auth.role() = 'anon');
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;

  -- Permitir actualización solo al propietario del perfil o si es anónimo
  BEGIN
    CREATE POLICY "Permitir actualización de perfiles" 
      ON public.profiles FOR UPDATE 
      USING (auth.uid() = id OR auth.role() = 'anon');
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;

  -- Habilitar RLS en la tabla profiles
  ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

  -- Crear trigger para actualizar el campo updated_at automáticamente
  BEGIN
    -- Usar EXECUTE para definir la función del trigger
    EXECUTE '
    CREATE OR REPLACE FUNCTION update_profiles_updated_at()
    RETURNS TRIGGER AS $BODY$
    BEGIN
      NEW.updated_at = now();
      RETURN NEW;
    END;
    $BODY$ LANGUAGE plpgsql;
    ';

    -- Eliminar el trigger si existe
    DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
    
    -- Crear el trigger
    CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_profiles_updated_at();
  EXCEPTION
    WHEN others THEN
      NULL;
  END;

  RETURN TRUE;
END;
$$; 