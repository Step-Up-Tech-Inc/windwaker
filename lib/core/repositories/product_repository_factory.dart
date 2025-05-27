import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'product_repository_interface.dart';
import 'supabase_product_repository.dart';

class ProductRepositoryFactory {
  static final ProductRepositoryFactory _instance =
      ProductRepositoryFactory._internal();

  factory ProductRepositoryFactory() => _instance;

  ProductRepositoryFactory._internal();

  final _logger = Logger();

  ProductRepositoryInterface? _currentRepository;
  bool _isInitialized = false;
  final _completer = Completer<void>();

  Future<void> initialize({
    required SharedPreferences sharedPreferences,
    required SupabaseClient supabaseClient,
  }) async {
    if (_isInitialized) {
      return _completer.future;
    }

    // Crear repositorio de Supabase
    final supabaseRepository = SupabaseProductRepository(supabaseClient);

    // Siempre usar Supabase como repositorio principal
    _currentRepository = supabaseRepository;
    _logger.i(
      'ProductRepositoryFactory: Usando Supabase como única fuente de datos',
    );

    _isInitialized = true;
    _completer.complete();
    return _completer.future;
  }

  ProductRepositoryInterface get repository {
    if (_currentRepository == null) {
      throw Exception(
        'ProductRepositoryFactory no ha sido inicializado. '
        'Llama a initialize() primero.',
      );
    }
    return _currentRepository!;
  }
}
