/// Utilidades para números de teléfono.
///
/// La app opera en Costa Rica, así que un número de 8 dígitos se asume
/// nacional y se le antepone +506. Cualquier otro número debe venir en
/// formato internacional.
class PhoneNumber {
  PhoneNumber._();

  static const String _costaRicaPrefix = '506';

  /// Normaliza [input] a formato E.164 (ej: +50688888888).
  /// Retorna `null` si el número no es válido.
  static String? normalize(String input) {
    var cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    if (!RegExp(r'^\d{8,15}$').hasMatch(cleaned)) {
      return null;
    }

    // Número nacional de Costa Rica (8 dígitos)
    if (cleaned.length == 8) {
      return '+$_costaRicaPrefix$cleaned';
    }

    return '+$cleaned';
  }

  /// Valida el texto de un campo de teléfono. Retorna el mensaje de error
  /// o `null` si es válido.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número es obligatorio';
    }
    if (normalize(value.trim()) == null) {
      return 'Número inválido. Usa 8 dígitos (CR) o formato internacional.';
    }
    return null;
  }
}
