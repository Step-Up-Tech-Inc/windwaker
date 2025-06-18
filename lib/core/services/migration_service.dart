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
      } catch (createError) {
        _logger.e('Error al crear tabla de perfiles: $createError');
        // No lanzamos excepción para permitir que la app siga funcionando
      }
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
      
      -- Crear nuevas políticas simplificadas
      CREATE POLICY "Permitir todas las operaciones" ON profiles USING (true);
      
      -- Habilitar RLS en la tabla profiles
      ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
      ''';

      await _supabaseClient.rpc('exec_sql', params: {'sql': policiesSQL});
      _logger.i('Políticas de seguridad configuradas con éxito');
    } catch (e) {
      _logger.e('Error al configurar políticas de seguridad: $e');
    }
  }
}
