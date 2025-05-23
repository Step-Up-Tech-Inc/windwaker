import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'product_repository_interface.dart';
import 'local_product_repository.dart';
import 'supabase_product_repository.dart';

class ProductRepositoryFactory {
  static final ProductRepositoryFactory _instance =
      ProductRepositoryFactory._internal();

  factory ProductRepositoryFactory() => _instance;

  ProductRepositoryFactory._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
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

    final localRepository = LocalProductRepository(sharedPreferences);
    final supabaseRepository = SupabaseProductRepository(supabaseClient);

    // Comprobar conectividad inicial
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateRepository(
      connectivityResult: connectivityResult,
      localRepository: localRepository,
      supabaseRepository: supabaseRepository,
    );

    // Establecer un listener para cambios de conectividad
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      _updateRepository(
        connectivityResult: result,
        localRepository: localRepository,
        supabaseRepository: supabaseRepository,
      );
    });

    _isInitialized = true;
    _completer.complete();
    return _completer.future;
  }

  void _updateRepository({
    required ConnectivityResult connectivityResult,
    required LocalProductRepository localRepository,
    required SupabaseProductRepository supabaseRepository,
  }) {
    if (connectivityResult == ConnectivityResult.none) {
      _currentRepository = localRepository;
      _logger.i('ProductRepositoryFactory: Usando almacenamiento local');
    } else {
      _currentRepository = supabaseRepository;
      _logger.i('ProductRepositoryFactory: Usando Supabase');
    }

    // Se podría implementar sincronización en segundo plano aquí
    // cuando recuperamos la conexión
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

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
