import 'package:flutter_test/flutter_test.dart';
import 'package:windwaker/core/utils/phone_number.dart';

void main() {
  group('PhoneNumber.normalize', () {
    test('antepone +506 a números nacionales de 8 dígitos', () {
      expect(PhoneNumber.normalize('88888888'), '+50688888888');
    });

    test('ignora espacios, guiones y paréntesis', () {
      expect(PhoneNumber.normalize('8888 8888'), '+50688888888');
      expect(PhoneNumber.normalize('8888-8888'), '+50688888888');
      expect(PhoneNumber.normalize('(8888) 8888'), '+50688888888');
    });

    test('conserva números ya en formato internacional', () {
      expect(PhoneNumber.normalize('+50688888888'), '+50688888888');
      expect(PhoneNumber.normalize('50688888888'), '+50688888888');
      expect(PhoneNumber.normalize('+5215512345678'), '+5215512345678');
    });

    test('rechaza números demasiado cortos o largos', () {
      expect(PhoneNumber.normalize('1234567'), isNull);
      expect(PhoneNumber.normalize('1234567890123456'), isNull);
    });

    test('rechaza entradas con letras o vacías', () {
      expect(PhoneNumber.normalize('ochocientos'), isNull);
      expect(PhoneNumber.normalize('8888888a'), isNull);
      expect(PhoneNumber.normalize(''), isNull);
    });
  });

  group('PhoneNumber.validate', () {
    test('retorna null para números válidos', () {
      expect(PhoneNumber.validate('88888888'), isNull);
      expect(PhoneNumber.validate('+50688888888'), isNull);
    });

    test('retorna mensaje para campo vacío', () {
      expect(PhoneNumber.validate(null), 'El número es obligatorio');
      expect(PhoneNumber.validate('  '), 'El número es obligatorio');
    });

    test('retorna mensaje para números inválidos', () {
      expect(
        PhoneNumber.validate('123'),
        'Número inválido. Usa 8 dígitos (CR) o formato internacional.',
      );
    });
  });
}
