// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role:
          $enumDecodeNullable(
            _$UserRoleEnumMap,
            json['role'],
            unknownValue: UserRole.customer,
          ) ??
          UserRole.customer,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
    };

const _$UserRoleEnumMap = {
  UserRole.customer: 'customer',
  UserRole.business: 'business',
  UserRole.driver: 'driver',
  UserRole.admin: 'admin',
};
