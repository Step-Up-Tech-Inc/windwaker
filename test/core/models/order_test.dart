import 'package:flutter_test/flutter_test.dart';
import 'package:windwaker/core/models/order.dart';

void main() {
  group('Order.fromJson', () {
    test('mapea una fila de orders con items y nombre de tienda', () {
      final order = Order.fromJson(const {
        'id': 'order-1',
        'customer_id': 'user-1',
        'store_id': 'store-1',
        'driver_id': null,
        'status': 'preparing',
        'delivery_method': 'delivery',
        'payment_method': 'sinpe',
        'address_label': 'Casa',
        'address_detail': '200m Este del Banco Nacional',
        'subtotal': 11800,
        'delivery_fee': 1500.5,
        'total': 13300.5,
        'created_at': '2026-07-01T12:00:00Z',
        'updated_at': '2026-07-01T12:10:00Z',
        'store_name': 'Soda La Amistad',
        'items': [
          {
            'id': 'item-1',
            'order_id': 'order-1',
            'product_id': 'prod-1',
            'product_name': 'Casado Típico',
            'unit_price': 4500,
            'quantity': 2,
          },
        ],
      });

      expect(order.status, OrderStatus.preparing);
      expect(order.paymentMethod, OrderPaymentMethod.sinpe);
      expect(order.deliveryMethod, DeliveryMethod.delivery);
      expect(order.subtotal, 11800.0);
      expect(order.deliveryFee, 1500.5);
      expect(order.total, 13300.5);
      expect(order.storeName, 'Soda La Amistad');
      expect(order.items, hasLength(1));
      expect(order.items.first.productName, 'Casado Típico');
      expect(order.items.first.quantity, 2);
    });

    test('parsea picked_up (snake_case) correctamente', () {
      final order = Order.fromJson(const {
        'id': 'o',
        'customer_id': 'c',
        'store_id': 's',
        'status': 'picked_up',
        'subtotal': 1,
        'total': 1,
        'created_at': '2026-07-01T12:00:00Z',
      });
      expect(order.status, OrderStatus.pickedUp);
    });
  });

  group('OrderStatus wire', () {
    test('ida y vuelta para todos los estados', () {
      for (final status in OrderStatus.values) {
        expect(orderStatusFromWire(status.wire), status);
      }
    });

    test('lanza ante un estado desconocido', () {
      expect(() => orderStatusFromWire('flying'), throwsArgumentError);
    });
  });

  group('Order.isFinal / isActive', () {
    Order withStatus(OrderStatus s) => Order(
          id: 'o',
          customerId: 'c',
          storeId: 's',
          status: s,
          subtotal: 1,
          total: 1,
          createdAt: DateTime(2026, 7, 1),
        );

    test('delivered, rejected y cancelled son terminales', () {
      expect(withStatus(OrderStatus.delivered).isFinal, isTrue);
      expect(withStatus(OrderStatus.rejected).isFinal, isTrue);
      expect(withStatus(OrderStatus.cancelled).isFinal, isTrue);
    });

    test('los demás estados son activos', () {
      for (final s in [
        OrderStatus.pending,
        OrderStatus.accepted,
        OrderStatus.preparing,
        OrderStatus.ready,
        OrderStatus.pickedUp,
      ]) {
        expect(withStatus(s).isActive, isTrue, reason: '$s');
      }
    });
  });

  test('OrderStatusChange.fromJson parsea filas del historial', () {
    final change = OrderStatusChange.fromJson(const {
      'status': 'accepted',
      'created_at': '2026-07-01T12:05:00Z',
    });
    expect(change.status, OrderStatus.accepted);
    expect(change.createdAt, DateTime.utc(2026, 7, 1, 12, 5));
  });
}
