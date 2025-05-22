import 'package:flutter/material.dart';

class CategoryCarousel extends StatelessWidget {
  const CategoryCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          CategoryItem(
            icon: Icons.restaurant,
            color: Color(0xFFFCE4EC),
            iconColor: Color(0xFFE91E63),
            title: 'Restaurantes',
          ),
          CategoryItem(
            icon: Icons.storefront,
            color: Color(0xFFE0F2F1),
            iconColor: Color(0xFF009688),
            title: 'Supermercados',
          ),
          CategoryItem(
            icon: Icons.shopping_basket,
            color: Color(0xFFE3F2FD),
            iconColor: Color(0xFF2196F3),
            title: 'Tiendas',
          ),
          CategoryItem(
            icon: Icons.local_pharmacy,
            color: Color(0xFFF3E5F5),
            iconColor: Color(0xFF9C27B0),
            title: 'Farmacias',
          ),
          CategoryItem(
            icon: Icons.local_florist,
            color: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
            title: 'Floristerías',
          ),
          CategoryItem(
            icon: Icons.liquor,
            color: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
            title: 'Licores',
          ),
          CategoryItem(
            icon: Icons.pets,
            color: Color(0xFFEFEBE9),
            iconColor: Color(0xFF795548),
            title: 'Mascotas',
          ),
          CategoryItem(
            icon: Icons.more_horiz,
            color: Color(0xFFE8EAF6),
            iconColor: Color(0xFF3F51B5),
            title: 'Más',
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final String title;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
