import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4.0, 16.0, 16.0, 10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 26),
                tooltip: 'Volver',
                onPressed: () => context.go('/home'),
              ),
              const Text(
                'Tilarán en Línea',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 28),
                onPressed: () {
                  // Sin funcionalidad por ahora
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, size: 28),
                onPressed: () {
                  // Sin funcionalidad por ahora
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
