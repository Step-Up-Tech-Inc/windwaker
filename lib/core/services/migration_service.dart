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

      // Crear función para verificar si una tabla existe
      await _createCheckTableExistsFunction();

      // Verificar y crear tabla de perfiles si no existe
      await _createProfilesTableIfNotExists();

      _logger.i('Migraciones completadas con éxito');
    } catch (e) {
      _logger.e('Error al ejecutar migraciones: $e');
    }
  }

  /// Crea una función para verificar si una tabla existe
  Future<void> _createCheckTableExistsFunction() async {
    try {
      _logger.i('Creando función check_table_exists...');

      const String functionSQL = '''
      CREATE OR REPLACE FUNCTION check_table_exists(table_name text)
      RETURNS boolean AS \$\$
      BEGIN
        RETURN EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_schema = 'public'
          AND table_name = \$1
        );
      END;
      \$\$ LANGUAGE plpgsql SECURITY DEFINER;
      ''';

      await _supabaseClient.rpc('exec_sql', params: {'sql': functionSQL});
      _logger.i('Función check_table_exists creada con éxito');
    } catch (e) {
      _logger.e('Error al crear función check_table_exists: $e');
    }
  }

  /// Verifica si la tabla de perfiles existe y la crea si no
  Future<void> _createProfilesTableIfNotExists() async {
    try {
      // Intentar consultar la tabla para verificar si existe
      await _supabaseClient.from('profiles').select('id').limit(1);
      _logger.i('Tabla de perfiles ya existe');
    } catch (e) {
      _logger.w('Tabla de perfiles no encontrada, creando...');

      try {
        // Ejecutar SQL para crear la tabla
        await _supabaseClient.rpc('create_profiles_table');
        _logger.i('Tabla de perfiles creada con éxito');
      } catch (createError) {
        _logger.e('Error al crear tabla de perfiles: $createError');
        // No lanzamos excepción para permitir que la app siga funcionando

        // Intentar método alternativo
        await _createProfilesTableDirectly();
      }
    }
  }

  /// Crea la tabla de perfiles directamente con SQL
  Future<void> _createProfilesTableDirectly() async {
    try {
      _logger.i('Intentando crear tabla de perfiles directamente con SQL...');

      // SQL para crear la tabla con sintaxis más simple
      const String createTableSQL = '''
      CREATE TABLE IF NOT EXISTS profiles (
        id UUID PRIMARY KEY,
        email TEXT,
        phone TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      ''';

      // Ejecutar SQL
      await _supabaseClient.rpc('exec_sql', params: {'sql': createTableSQL});
      _logger.i('Tabla de perfiles creada directamente con SQL');

      // Crear políticas de seguridad simplificadas
      const String policiesSQL = '''
      -- Desactivar RLS temporalmente para permitir la creación inicial
      ALTER TABLE IF EXISTS profiles DISABLE ROW LEVEL SECURITY;
      
      -- Eliminar políticas existentes si hay
      DROP POLICY IF EXISTS "Permitir lectura pública de perfiles" ON profiles;
      DROP POLICY IF EXISTS "Permitir inserción de perfiles" ON profiles;
      DROP POLICY IF EXISTS "Permitir actualización de perfiles" ON profiles;
      
      -- Crear nuevas políticas simplificadas
      CREATE POLICY "Permitir todas las operaciones" ON profiles USING (true);
      
      -- Habilitar RLS en la tabla profiles
      ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
      ''';

      await _supabaseClient.rpc('exec_sql', params: {'sql': policiesSQL});
      _logger.i('Políticas de seguridad simplificadas creadas');
    } catch (e) {
      _logger.e('Error al crear tabla de perfiles directamente: $e');
    }
  }
}
