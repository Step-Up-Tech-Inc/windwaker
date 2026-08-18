import 'package:flutter_test/flutter_test.dart';
import 'package:windwaker/core/models/profile.dart';

void main() {
  group('Profile.fromJson', () {
    test('mapea una fila completa de la tabla profiles', () {
      final profile = Profile.fromJson(const {
        'id': 'user-1',
        'email': 'edgar@test.com',
        'phone': '+50688888888',
        'role': 'business',
        'full_name': 'Edgar Alvarado',
        'avatar_url': 'https://example.com/a.png',
      });

      expect(profile.id, 'user-1');
      expect(profile.email, 'edgar@test.com');
      expect(profile.phone, '+50688888888');
      expect(profile.role, UserRole.business);
      expect(profile.fullName, 'Edgar Alvarado');
      expect(profile.avatarUrl, 'https://example.com/a.png');
    });

    test('usa customer cuando la fila no trae rol (filas pre-migración)', () {
      final profile = Profile.fromJson(const {'id': 'user-1'});
      expect(profile.role, UserRole.customer);
    });

    test('usa customer ante un rol desconocido', () {
      final profile = Profile.fromJson(const {
        'id': 'user-1',
        'role': 'superadmin',
      });
      expect(profile.role, UserRole.customer);
    });

    test('parsea todos los roles válidos', () {
      for (final entry in {
        'customer': UserRole.customer,
        'business': UserRole.business,
        'driver': UserRole.driver,
        'admin': UserRole.admin,
      }.entries) {
        final profile = Profile.fromJson({'id': 'u', 'role': entry.key});
        expect(profile.role, entry.value, reason: 'rol ${entry.key}');
      }
    });
  });

  group('Profile.isComplete', () {
    test('completo con email y teléfono', () {
      const profile = Profile(
        id: 'u',
        email: 'a@b.com',
        phone: '+50688888888',
      );
      expect(profile.isComplete, isTrue);
    });

    test('incompleto sin email, sin teléfono, o vacíos', () {
      expect(const Profile(id: 'u', phone: '+506').isComplete, isFalse);
      expect(const Profile(id: 'u', email: 'a@b.com').isComplete, isFalse);
      expect(
        const Profile(id: 'u', email: '', phone: '').isComplete,
        isFalse,
      );
    });
  });
}
