import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/repositories/store_repository.dart';
import 'cubit/search_cubit.dart';
import 'cubit/search_state.dart';
import 'widgets/search_header.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/category_selector.dart';
import 'widgets/store_card.dart';
import 'widgets/bottom_navigation.dart';
import '../store/store_products_screen.dart';

class SearchScreen extends StatelessWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SearchCubit(storeRepository: StoreRepository())..init();

        // Si hay una consulta inicial, realizar la búsqueda
        if (initialQuery != null && initialQuery!.isNotEmpty) {
          Future.microtask(() => cubit.searchStores(initialQuery!));
        }

        return cubit;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Encabezado y barra de búsqueda (fijos)
              const SearchHeader(),
              SearchBarWidget(initialQuery: initialQuery),
              const CategorySelector(),

              // Lista de tiendas (scrollable)
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              SelectableText.rich(
                                TextSpan(
                                  text: 'Ocurrió un error\n\n',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: state.errorMessage,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed:
                                    () => context.read<SearchCubit>().init(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2979FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Si hay búsqueda o filtro por categoría, mostrar solo los resultados
                    if (state.searchQuery.isNotEmpty ||
                        state.selectedCategory.isNotEmpty) {
                      if (state.stores.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.store_mall_directory_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No se encontraron tiendas',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: Text(
                                  state.searchQuery.isNotEmpty
                                      ? 'No hay resultados para "${state.searchQuery}". Intenta con otra búsqueda.'
                                      : state.selectedCategory.isNotEmpty
                                      ? 'No hay tiendas en la categoría "${state.selectedCategory}".'
                                      : 'No hay tiendas disponibles en este momento.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        itemCount: state.stores.length,
                        itemBuilder: (context, index) {
                          final store = state.stores[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: StoreCard(
                              store: store,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => StoreProductsScreen(
                                          storeId: store.id,
                                          storeName: store.name,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }

                    // Vista principal cuando no hay búsqueda ni filtros
                    return ListView(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      children: [
                        // Todas las tiendas
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            'Todas las tiendas',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),

                        if (state.stores.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'No hay tiendas disponibles en este momento.',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          ...state.stores.map(
                            (store) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: StoreCard(
                                store: store,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => StoreProductsScreen(
                                            storeId: store.id,
                                            storeName: store.name,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavigation(currentIndex: 1),
      ),
    );
  }
}
