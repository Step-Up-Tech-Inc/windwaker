import 'package:flutter_test/flutter_test.dart';
import 'package:windwaker/core/models/address.dart';
import 'package:windwaker/core/models/order.dart';

void main() {
  group('PaymentStatus en Order', () {
    Order orderFrom(Map<String, dynamic> extra) => Order.fromJson({
          'id': 'o',
          'customer_id': 'c',
          'store_id': 's',
          'subtotal': 1,
          'total': 1,
          'created_at': '2026-07-04T12:00:00Z',
          ...extra,
        });

    test('pedido SINPE con comprobante enviado', () {
      final order = orderFrom(const {
        'payment_method': 'sinpe',
        'payment_status': 'submitted',
        'payment_reference': 'REF-123',
        'store_sinpe_number': '88887777',
      });
      expect(order.paymentStatus, PaymentStatus.submitted);
      expect(order.paymentReference, 'REF-123');
      expect(order.storeSinpeNumber, '88887777');
    });

    test('pedido en efectivo no requiere pago', () {
      final order = orderFrom(const {'payment_method': 'cash'});
      expect(order.paymentStatus, PaymentStatus.notRequired);
    });

    test('todos los estados de pago parsean', () {
      for (final wire in [
        'not_required',
        'pending',
        'submitted',
        'verified',
        'rejected',
      ]) {
        expect(
          () => orderFrom({'payment_status': wire}),
          returnsNormally,
          reason: wire,
        );
      }
    });
  });

  group('Address.fullDetail', () {
    test('combina señas, referencia y distrito', () {
      const address = Address(
        id: 'a',
        userId: 'u',
        label: 'Casa',
        detail: '200m Este del Banco Nacional',
        district: 'Tilarán',
        reference: 'portón negro',
      );
      expect(
        address.fullDetail,
        '200m Este del Banco Nacional · Ref: portón negro · Tilarán',
      );
    });

    test('sin extras deja solo las señas', () {
      const address = Address(
        id: 'a',
        userId: 'u',
        label: 'Casa',
        detail: 'Frente a la escuela',
      );
      expect(address.fullDetail, 'Frente a la escuela');
    });
  });
}
