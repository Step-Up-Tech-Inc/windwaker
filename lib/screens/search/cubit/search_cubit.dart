import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/store_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final StoreRepository _storeRepository;

  SearchCubit({required StoreRepository storeRepository})
    : _storeRepository = storeRepository,
      super(const SearchState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final stores = await _storeRepository.getStores();
      final Set<String> uniqueCategories =
          stores.map((store) => store.category).toSet();

      emit(
        state.copyWith(
          stores: stores,
          categories: uniqueCategories.toList(),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Error al cargar tiendas: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> searchStores(String query) async {
    if (query.isEmpty) {
      await init();
      return;
    }

    emit(
      state.copyWith(searchQuery: query, isLoading: true, errorMessage: null),
    );

    try {
      final stores = await _storeRepository.searchStores(query);
      emit(state.copyWith(stores: stores, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Error al buscar tiendas: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> filterByCategory(String category) async {
    emit(
      state.copyWith(
        selectedCategory: category,
        isLoading: true,
        errorMessage: null,
      ),
    );

    try {
      final stores =
          category.isEmpty
              ? await _storeRepository.getStores()
              : await _storeRepository.getStoresByCategory(category);

      emit(state.copyWith(stores: stores, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Error al filtrar tiendas: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  void clearFilters() {
    emit(state.copyWith(searchQuery: '', selectedCategory: ''));
    init();
  }
}
