// @JsonKey sobre parámetros de constructor es el patrón oficial de
// freezed + json_serializable; el analizador lo marca pero el generador lo usa.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Rol de un usuario dentro del marketplace.
enum UserRole {
  @JsonValue('customer')
  customer,
  @JsonValue('business')
  business,
  @JsonValue('driver')
  driver,
  @JsonValue('admin')
  admin,
}

/// Perfil de usuario (tabla `profiles` de Supabase).
@freezed
class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    String? email,
    String? phone,
    @JsonKey(unknownEnumValue: UserRole.customer)
    @Default(UserRole.customer)
    UserRole role,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  /// El registro está completo cuando el usuario ya tiene email y teléfono.
  bool get isComplete =>
      (email?.isNotEmpty ?? false) && (phone?.isNotEmpty ?? false);
}
