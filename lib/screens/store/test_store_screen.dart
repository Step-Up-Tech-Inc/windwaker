import 'package:flutter/material.dart';
import 'store_products_screen.dart';

class TestStoreScreen extends StatelessWidget {
  const TestStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Store')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => const StoreProductsScreen(
                      storeId: 'store1',
                      storeName: 'Super Económico',
                    ),
              ),
            );
          },
          child: const Text('Ver Super Económico'),
        ),
      ),
    );
  }
}
