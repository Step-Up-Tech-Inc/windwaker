import 'package:flutter/material.dart';

class PromotionCarousel extends StatefulWidget {
  const PromotionCarousel({super.key});

  @override
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  // Lista de imágenes de promoción (en este caso usaremos placeholders)
  final List<Map<String, String>> _promotions = [
    {
      'title': 'Descuentos especiales',
      'description': 'Hasta 50% en restaurantes seleccionados',
      'color': '#FF5252',
    },
    {
      'title': 'Envío gratis',
      'description': 'En tu primer pedido',
      'color': '#448AFF',
    },
    {
      'title': 'Nuevos restaurantes',
      'description': 'Descubre nuevos sabores',
      'color': '#66BB6A',
    },
    {
      'title': 'Promociones de temporada',
      'description': 'Aprovecha las ofertas limitadas',
      'color': '#FFA726',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _promotions.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final promotion = _promotions[index];
              final color = Color(
                int.parse(
                  promotion['color']!.substring(1).padLeft(8, 'ff'),
                  radix: 16,
                ),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: color,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.restaurant,
                            size: 150,
                            color: Colors.white.withAlpha(51),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                promotion['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                promotion['description']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promotions.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
