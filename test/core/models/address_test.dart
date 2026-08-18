import 'package:flutter_test/flutter_test.dart';
import 'package:windwaker/core/models/address.dart';

void main() {
  test('Address.fromJson mapea una fila de la tabla addresses', () {
    final address = Address.fromJson(const {
      'id': 'addr-1',
      'user_id': 'user-1',
      'label': 'Casa',
      'detail': '200m Este del Banco Nacional, casa verde',
      'latitude': 10.4626,
      'longitude': -84.9718,
      'is_default': true,
      'created_at': '2026-07-01T12:00:00Z',
    });

    expect(address.id, 'addr-1');
    expect(address.userId, 'user-1');
    expect(address.label, 'Casa');
    expect(address.detail, contains('Banco Nacional'));
    expect(address.latitude, closeTo(10.4626, 0.0001));
    expect(address.isDefault, isTrue);
  });

  test('is_default ausente se interpreta como false', () {
    final address = Address.fromJson(const {
      'id': 'addr-2',
      'user_id': 'user-1',
      'label': 'Trabajo',
      'detail': 'Frente a la escuela',
    });

    expect(address.isDefault, isFalse);
    expect(address.latitude, isNull);
  });
}
