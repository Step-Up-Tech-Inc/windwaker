import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

/// Servicio para ejecutar migraciones en la base de datos
class MigrationService {
  final SupabaseClient _supabaseClient;
  final _logger = Logger();

  MigrationService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Ejecuta todas las migraciones necesarias
  Future<void> runMigrations() async {
    try {
      _logger.i('Iniciando migraciones de base de datos...');

      // Verificar y crear tabla de perfiles si no existe
      await _createProfilesTableIfNotExists();

      // Ejecutar la función RPC para crear la tabla de perfiles
      await _executeCreateProfilesRPC();

      // Crear trigger para sincronizar email entre auth.users y profiles
      await _createEmailSyncTrigger();

      _logger.i('Migraciones completadas con éxito');
    } catch (e) {
      _logger.e('Error al ejecutar migraciones: $e');
    }
  }

  /// Verifica si la tabla de perfiles existe y la crea si no
  Future<void> _createProfilesTableIfNotExists() async {
    try {
      // Intentar consultar la tabla para verificar si existe
      await _supabaseClient.from('profiles').select('id').limit(1);
      _logger.i('Tabla de perfiles ya existe');

      // Verificar si los triggers están configurados correctamente
      await _verifyAndFixTriggers();

      // Actualizar políticas de seguridad para permitir operaciones anónimas
      await _updateProfilesSecurity();
    } catch (e) {
      _logger.w('Tabla de perfiles no encontrada, creando...');

      try {
        // Crear tabla directamente usando SQL
        const String createTableSQL = '''
        CREATE TABLE IF NOT EXISTS profiles (
          id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
          email TEXT,
          phone TEXT,
          created_at TIMESTAMPTZ DEFAULT now(),
          updated_at TIMESTAMPTZ DEFAULT now()
        );
        ''';

        await _supabaseClient.rpc('exec_sql', params: {'sql': createTableSQL});
        _logger.i('Tabla de perfiles creada con éxito');

        // Configurar políticas de seguridad
        await _configureProfilesSecurity();

        // Crear función para actualizar el campo updated_at
        final createFunctionSQL = r'''
        CREATE OR REPLACE FUNCTION update_profiles_updated_at()
        RETURNS TRIGGER 
        LANGUAGE plpgsql
        AS $BODY$
        BEGIN
          NEW.updated_at = now();
          RETURN NEW;
        END;
        $BODY$
        ''';

        await _supabaseClient.rpc(
          'exec_sql',
          params: {'sql': createFunctionSQL},
        );
        _logger.i('Función para actualización de fecha creada con éxito');

        // Eliminar trigger si existe y crear uno nuevo
        final createTriggerSQL = r'''
        DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
        
        CREATE TRIGGER update_profiles_updated_at
        BEFORE UPDATE ON profiles
        FOR EACH ROW
        EXECUTE FUNCTION update_profiles_updated_at();
        ''';

        await _supabaseClient.rpc(
          'exec_sql',
          params: {'sql': createTriggerSQL},
        );
        _logger.i('Trigger para actualización de fecha creado con éxito');
      } catch (createError) {
        _logger.e('Error al crear tabla de perfiles: $createError');
        // No lanzamos excepción para permitir que la app siga funcionando
      }
    }
  }

  /// Actualiza las políticas de seguridad para permitir operaciones anónimas
  Future<void> _updateProfilesSecurity() async {
    try {
      _logger.i('Actualizando políticas de seguridad para profiles...');

      // Eliminar políticas existentes
      const String dropPoliciesSQL = '''
      DROP POLICY IF EXISTS "Permitir lectura pública de perfiles" ON profiles;
      DROP POLICY IF EXISTS "Permitir inserción de perfiles" ON profiles;
      DROP POLICY IF EXISTS "Permitir actualización de perfiles" ON profiles;
      DROP POLICY IF EXISTS "Permitir todas las operaciones" ON profiles;
      ''';

      await _supabaseClient.rpc('exec_sql', params: {'sql': dropPoliciesSQL});
      _logger.i('Políticas existentes eliminadas');

      // Crear nuevas políticas
      const String createPoliciesSQL = '''
      -- Permitir lectura pública
      CREATE POLICY "Permitir lectura pública de perfiles" 
        ON profiles FOR SELECT 
        USING (true);
      
      -- Permitir inserción para cualquier usuario
      CREATE POLICY "Permitir inserción de perfiles" 
        ON profiles FOR INSERT 
        WITH CHECK (true);
      
      -- Permitir actualización para cualquier usuario
      CREATE POLICY "Permitir actualización de perfiles" 
        ON profiles FOR UPDATE 
        USING (true);
      ''';

      await _supabaseClient.rpc('exec_sql', params: {'sql': createPoliciesSQL});
      _logger.i('Nuevas políticas creadas con éxito');
    } catch (e) {
      _logger.e('Error al actualizar políticas de seguridad: $e');
    }
  }

  /// Verifica y corrige los triggers de la tabla profiles
  Future<void> _verifyAndFixTriggers() async {
    try {
      _logger.i('Verificando triggers de la tabla profiles...');

      // Recrear la función de actualización de fecha
      final recreateFunctionSQL = r'''
      CREATE OR REPLACE FUNCTION update_profiles_updated_at()
      RETURNS TRIGGER 
      LANGUAGE plpgsql
      AS $BODY$
      BEGIN
        NEW.updated_at = now();
        RETURN NEW;
      END;
      $BODY$
      ''';

      await _supabaseClient.rpc(
        'exec_sql',
        params: {'sql': recreateFunctionSQL},
      );
      _logger.i('Función para actualización de fecha recreada');

      // Recrear el trigger
      final recreateTriggerSQL = r'''
      DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
      
      CREATE TRIGGER update_profiles_updated_at
      BEFORE UPDATE ON profiles
      FOR EACH ROW
      EXECUTE FUNCTION update_profiles_updated_at();
      ''';

      await _supabaseClient.rpc(
        'exec_sql',
        params: {'sql': recreateTriggerSQL},
      );
      _logger.i('Trigger para actualización de fecha recreado');
    } catch (e) {
      _logger.e('Error al verificar/corregir triggers: $e');
    }
  }

  /// Ejecuta la función RPC create_profiles_table
  Future<void> _executeCreateProfilesRPC() async {
    try {
      _logger.i('Ejecutando función RPC create_profiles_table...');
      final result = await _supabaseClient.rpc('create_profiles_table');
      _logger.i(
        'Función RPC create_profiles_table ejecutada con éxito: $result',
      );
    } catch (e) {
      _logger.e('Error al ejecutar función RPC create_profiles_table: $e');
      // No lanzamos excepción para permitir que la app siga funcionando
    }
  }

  /// Configura las políticas de seguridad para la tabla profiles
  Future<void> _configureProfilesSecurity() async {
    try {
      _logger.i('Configurando políticas de seguridad para profiles...');

      // Desactivar RLS temporalmente
      await _supabaseClient.rpc(
        'exec_sql',
        params: {'sql': 'ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;'},
      );

      // Crear políticas de seguridad básicas
      const String policiesSQL = '''
      -- Eliminar políticas existentes si hay
      DROP POLICY IF EXISTS "Permitir lectura pública de perfiles" ON profiles;
      DROP POLICY IF EXISTS "Permitir inserción de perfiles" ON profiles;
      DROP POLICY IF EXISTS "Permitir actualización de perfiles" ON profiles;
      DROP POLICY IF EXISTS "Permitir todas las operaciones" ON profiles;
      
      -- Crear políticas que permitan todas las operaciones
      CREATE POLICY "Permitir lectura pública de perfiles" 
        ON profiles FOR SELECT 
        USING (true);
      
      CREATE POLICY "Permitir inserción de perfiles" 
        ON profiles FOR INSERT 
        WITH CHECK (true);
      
      CREATE POLICY "Permitir actualización de perfiles" 
        ON profiles FOR UPDATE 
        USING (true);
      
      -- Habilitar RLS en la tabla profiles
      ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
      ''';

      await _supabaseClient.rpc('exec_sql', params: {'sql': policiesSQL});
      _logger.i('Políticas de seguridad configuradas con éxito');
    } catch (e) {
      _logger.e('Error al configurar políticas de seguridad: $e');
    }
  }

  /// Crea un trigger para sincronizar el email entre auth.users y profiles
  Future<void> _createEmailSyncTrigger() async {
    try {
      _logger.i('Creando trigger para sincronizar email...');

      // Crear función para manejar actualizaciones de email
      final createUpdateFunctionSQL = r'''
      CREATE OR REPLACE FUNCTION public.handle_auth_user_email_update()
      RETURNS TRIGGER
      LANGUAGE plpgsql
      SECURITY DEFINER SET search_path = public
      AS $$
      BEGIN
        UPDATE public.profiles
        SET email = NEW.email, updated_at = NOW()
        WHERE id = NEW.id;
        RETURN NEW;
      END;
      $$;
      ''';

      await _supabaseClient.rpc(
        'exec_sql',
        params: {'sql': createUpdateFunctionSQL},
      );
      _logger.i('Función para sincronizar email creada con éxito');

      // Crear trigger en la tabla auth.users
      final createTriggerSQL = r'''
      DROP TRIGGER IF EXISTS sync_email_to_profiles ON auth.users;
      
      CREATE TRIGGER sync_email_to_profiles
      AFTER UPDATE OF email ON auth.users
      FOR EACH ROW
      WHEN (OLD.email IS DISTINCT FROM NEW.email)
      EXECUTE FUNCTION public.handle_auth_user_email_update();
      ''';

      await _supabaseClient.rpc('exec_sql', params: {'sql': createTriggerSQL});
      _logger.i('Trigger para sincronizar email creado con éxito');
    } catch (e) {
      _logger.e('Error al crear trigger de sincronización: $e');
    }
  }
}
