import '../models/cart_item.dart';
import '../models/order.dart';

/// Convierte las líneas de un pedido anterior en ítems de carrito para
/// "volver a pedir". Usa el snapshot del pedido (nombre/precio de aquel
/// momento) solo para mostrar: al hacer checkout, `create_order` recalcula
/// los precios vigentes en el servidor.
List<CartItem> cartItemsFromOrder(Order order) {
  return [
    for (final item in order.items)
      if (item.productId != null)
        CartItem(
          id: '',
          productId: item.productId!,
          productName: item.productName,
          imageUrl: '',
          price: item.unitPrice,
          unit: 'unidad',
          quantity: item.quantity.toDouble(),
          storeId: order.storeId,
        ),
  ];
}
