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
                          padding: const EdgeInsets.all(20),
                          child: SelectableText.rich(
                            TextSpan(
                              text: 'Error: ',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: state.errorMessage,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (state.stores.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No se encontraron tiendas',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              state.searchQuery.isNotEmpty
                                  ? 'Intenta con otra búsqueda'
                                  : state.selectedCategory.isNotEmpty
                                  ? 'No hay tiendas en esta categoría'
                                  : 'No hay tiendas disponibles',
                              style: Theme.of(context).textTheme.bodyMedium,
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
                              // Por ahora solo mostramos un mensaje
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Seleccionaste: ${store.name}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        );
                      },
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
