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

  -- Eliminar políticas existentes si hay
  BEGIN
    DROP POLICY IF EXISTS "Permitir lectura pública de perfiles" ON public.profiles;
    DROP POLICY IF EXISTS "Permitir inserción de perfiles" ON public.profiles;
    DROP POLICY IF EXISTS "Permitir actualización de perfiles" ON public.profiles;
    DROP POLICY IF EXISTS "Permitir todas las operaciones" ON public.profiles;
  EXCEPTION
    WHEN others THEN
      NULL;
  END;

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

  -- Permitir inserción para cualquier usuario (anónimo o autenticado)
  BEGIN
    CREATE POLICY "Permitir inserción de perfiles" 
      ON public.profiles FOR INSERT 
      WITH CHECK (true);
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;

  -- Permitir actualización para cualquier usuario (anónimo o autenticado)
  BEGIN
    CREATE POLICY "Permitir actualización de perfiles" 
      ON public.profiles FOR UPDATE 
      USING (true);
  EXCEPTION
    WHEN duplicate_object THEN
      NULL;
  END;

  -- Habilitar RLS en la tabla profiles
  ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

  -- Crear trigger para actualizar el campo updated_at automáticamente
  BEGIN
    -- Eliminar la función y el trigger si existen para evitar errores
    DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
    DROP FUNCTION IF EXISTS update_profiles_updated_at();
    
    -- Crear la función del trigger con EXECUTE para evitar problemas de delimitadores
    EXECUTE 
    'CREATE OR REPLACE FUNCTION update_profiles_updated_at()
    RETURNS TRIGGER AS $BODY$
    BEGIN
      NEW.updated_at = now();
      RETURN NEW;
    END;
    $BODY$ LANGUAGE plpgsql';
    
    -- Crear el trigger
    EXECUTE
    'CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_profiles_updated_at()';
  EXCEPTION
    WHEN others THEN
      RAISE NOTICE 'Error al crear trigger: %', SQLERRM;
  END;

  RETURN TRUE;
END;
$$; 