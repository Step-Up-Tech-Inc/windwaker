// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

/// Dirección de entrega del usuario (tabla `addresses`).
/// En Tilarán no hay nomenclatura exacta: `detail` son las señas.
@freezed
class Address with _$Address {
  const Address._();

  const factory Address({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String label,
    required String detail,
    /// Distrito del cantón de Tilarán (Tilarán, Tronadora, Arenal…)
    String? district,
    /// Punto de referencia adicional ("frente al súper", "portón negro")
    String? reference,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  /// Señas + referencia + distrito en una sola línea (para el pedido).
  String get fullDetail => [
        detail,
        if (reference?.isNotEmpty ?? false) 'Ref: $reference',
        if (district?.isNotEmpty ?? false) district!,
      ].join(' · ');
}
