import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/negocio.dart';
import 'cubit/home_cubit.dart';
import 'widgets/promotion_carousel.dart';
import 'widgets/negocio_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => const SizedBox.shrink(),
              loading: (_) => const Center(child: CircularProgressIndicator()),
              loaded: (loaded) => _buildLoadedState(context, loaded),
              error:
                  (error) => Center(
                    child: SelectableText.rich(
                      TextSpan(
                        text: 'Error: ${error.message}',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, HomeState loaded) {
    // Extraer los datos del estado loaded
    final String ciudad = (loaded as dynamic).ciudad;
    final List<Negocio> negocios = (loaded as dynamic).negocios;

    return CustomScrollView(
      slivers: [
        _buildAppBar(ciudad),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar tiendas y productos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              enabled: true, // Está habilitado pero no hace nada
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text(
              'Promociones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        SliverToBoxAdapter(child: const PromotionCarousel()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Tiendas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final negocio = negocios[index];
              return NegocioCard(negocio: negocio);
            }, childCount: negocios.length),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(String ciudad) {
    return SliverAppBar(
      floating: true,
      title: Row(
        children: [
          const Icon(Icons.location_on, size: 20),
          const SizedBox(width: 4),
          Text(ciudad, style: const TextStyle(fontSize: 16)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Sin funcionalidad por ahora
          },
        ),
      ],
    );
  }
}
