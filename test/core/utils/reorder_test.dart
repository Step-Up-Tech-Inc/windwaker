import 'package:flutter_test/flutter_test.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/models/order_item.dart';
import 'package:windwaker/core/utils/reorder.dart';

void main() {
  Order orderWith(List<OrderItem> items) => Order(
        id: 'order-1',
        customerId: 'user-1',
        storeId: 'store-1',
        subtotal: 9000,
        total: 10500,
        createdAt: DateTime(2026, 7, 1),
        items: items,
      );

  test('convierte las líneas del pedido en ítems de carrito', () {
    const item = OrderItem(
      id: 'oi-1',
      orderId: 'order-1',
      productId: 'prod-1',
      productName: 'Casado Típico',
      unitPrice: 4500,
      quantity: 2,
    );

    final cartItems = cartItemsFromOrder(orderWith(const [item]));

    expect(cartItems, hasLength(1));
    expect(cartItems.first.productId, 'prod-1');
    expect(cartItems.first.productName, 'Casado Típico');
    expect(cartItems.first.quantity, 2.0);
    expect(cartItems.first.storeId, 'store-1');
  });

  test('omite líneas cuyo producto ya no existe (product_id null)', () {
    const deletedProductItem = OrderItem(
      id: 'oi-2',
      orderId: 'order-1',
      productId: null,
      productName: 'Producto descontinuado',
      unitPrice: 1000,
      quantity: 1,
    );

    final cartItems = cartItemsFromOrder(orderWith(const [deletedProductItem]));

    expect(cartItems, isEmpty);
  });
}
