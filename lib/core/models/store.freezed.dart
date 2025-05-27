// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Store _$StoreFromJson(Map<String, dynamic> json) {
  return _Store.fromJson(json);
}

/// @nodoc
mixin _$Store {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_time_minutes')
  int get deliveryTimeMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_fee')
  double get deliveryFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_open')
  bool get isOpen => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool get isFeatured => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreCopyWith<Store> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreCopyWith<$Res> {
  factory $StoreCopyWith(Store value, $Res Function(Store) then) =
      _$StoreCopyWithImpl<$Res, Store>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    @JsonKey(name: 'image_url') String imageUrl,
    String category,
    double rating,
    @JsonKey(name: 'delivery_time_minutes') int deliveryTimeMinutes,
    @JsonKey(name: 'delivery_fee') double deliveryFee,
    @JsonKey(name: 'is_open') bool isOpen,
    bool isFavorite,
    @JsonKey(name: 'is_featured') bool isFeatured,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });
}

/// @nodoc
class _$StoreCopyWithImpl<$Res, $Val extends Store>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? category = null,
    Object? rating = null,
    Object? deliveryTimeMinutes = null,
    Object? deliveryFee = null,
    Object? isOpen = null,
    Object? isFavorite = null,
    Object? isFeatured = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            imageUrl:
                null == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String,
            rating:
                null == rating
                    ? _value.rating
                    : rating // ignore: cast_nullable_to_non_nullable
                        as double,
            deliveryTimeMinutes:
                null == deliveryTimeMinutes
                    ? _value.deliveryTimeMinutes
                    : deliveryTimeMinutes // ignore: cast_nullable_to_non_nullable
                        as int,
            deliveryFee:
                null == deliveryFee
                    ? _value.deliveryFee
                    : deliveryFee // ignore: cast_nullable_to_non_nullable
                        as double,
            isOpen:
                null == isOpen
                    ? _value.isOpen
                    : isOpen // ignore: cast_nullable_to_non_nullable
                        as bool,
            isFavorite:
                null == isFavorite
                    ? _value.isFavorite
                    : isFavorite // ignore: cast_nullable_to_non_nullable
                        as bool,
            isFeatured:
                null == isFeatured
                    ? _value.isFeatured
                    : isFeatured // ignore: cast_nullable_to_non_nullable
                        as bool,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as String?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoreImplCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$$StoreImplCopyWith(
    _$StoreImpl value,
    $Res Function(_$StoreImpl) then,
  ) = __$$StoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    @JsonKey(name: 'image_url') String imageUrl,
    String category,
    double rating,
    @JsonKey(name: 'delivery_time_minutes') int deliveryTimeMinutes,
    @JsonKey(name: 'delivery_fee') double deliveryFee,
    @JsonKey(name: 'is_open') bool isOpen,
    bool isFavorite,
    @JsonKey(name: 'is_featured') bool isFeatured,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });
}

/// @nodoc
class __$$StoreImplCopyWithImpl<$Res>
    extends _$StoreCopyWithImpl<$Res, _$StoreImpl>
    implements _$$StoreImplCopyWith<$Res> {
  __$$StoreImplCopyWithImpl(
    _$StoreImpl _value,
    $Res Function(_$StoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? category = null,
    Object? rating = null,
    Object? deliveryTimeMinutes = null,
    Object? deliveryFee = null,
    Object? isOpen = null,
    Object? isFavorite = null,
    Object? isFeatured = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$StoreImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        imageUrl:
            null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String,
        rating:
            null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                    as double,
        deliveryTimeMinutes:
            null == deliveryTimeMinutes
                ? _value.deliveryTimeMinutes
                : deliveryTimeMinutes // ignore: cast_nullable_to_non_nullable
                    as int,
        deliveryFee:
            null == deliveryFee
                ? _value.deliveryFee
                : deliveryFee // ignore: cast_nullable_to_non_nullable
                    as double,
        isOpen:
            null == isOpen
                ? _value.isOpen
                : isOpen // ignore: cast_nullable_to_non_nullable
                    as bool,
        isFavorite:
            null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                    as bool,
        isFeatured:
            null == isFeatured
                ? _value.isFeatured
                : isFeatured // ignore: cast_nullable_to_non_nullable
                    as bool,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as String?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoreImpl implements _Store {
  _$StoreImpl({
    required this.id,
    required this.name,
    required this.description,
    @JsonKey(name: 'image_url') required this.imageUrl,
    required this.category,
    required this.rating,
    @JsonKey(name: 'delivery_time_minutes') required this.deliveryTimeMinutes,
    @JsonKey(name: 'delivery_fee') required this.deliveryFee,
    @JsonKey(name: 'is_open') required this.isOpen,
    this.isFavorite = false,
    @JsonKey(name: 'is_featured') this.isFeatured = false,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory _$StoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  final String category;
  @override
  final double rating;
  @override
  @JsonKey(name: 'delivery_time_minutes')
  final int deliveryTimeMinutes;
  @override
  @JsonKey(name: 'delivery_fee')
  final double deliveryFee;
  @override
  @JsonKey(name: 'is_open')
  final bool isOpen;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'Store(id: $id, name: $name, description: $description, imageUrl: $imageUrl, category: $category, rating: $rating, deliveryTimeMinutes: $deliveryTimeMinutes, deliveryFee: $deliveryFee, isOpen: $isOpen, isFavorite: $isFavorite, isFeatured: $isFeatured, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.deliveryTimeMinutes, deliveryTimeMinutes) ||
                other.deliveryTimeMinutes == deliveryTimeMinutes) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    imageUrl,
    category,
    rating,
    deliveryTimeMinutes,
    deliveryFee,
    isOpen,
    isFavorite,
    isFeatured,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreImplCopyWith<_$StoreImpl> get copyWith =>
      __$$StoreImplCopyWithImpl<_$StoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreImplToJson(this);
  }
}

abstract class _Store implements Store {
  factory _Store({
    required final String id,
    required final String name,
    required final String description,
    @JsonKey(name: 'image_url') required final String imageUrl,
    required final String category,
    required final double rating,
    @JsonKey(name: 'delivery_time_minutes')
    required final int deliveryTimeMinutes,
    @JsonKey(name: 'delivery_fee') required final double deliveryFee,
    @JsonKey(name: 'is_open') required final bool isOpen,
    final bool isFavorite,
    @JsonKey(name: 'is_featured') final bool isFeatured,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
  }) = _$StoreImpl;

  factory _Store.fromJson(Map<String, dynamic> json) = _$StoreImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  String get category;
  @override
  double get rating;
  @override
  @JsonKey(name: 'delivery_time_minutes')
  int get deliveryTimeMinutes;
  @override
  @JsonKey(name: 'delivery_fee')
  double get deliveryFee;
  @override
  @JsonKey(name: 'is_open')
  bool get isOpen;
  @override
  bool get isFavorite;
  @override
  @JsonKey(name: 'is_featured')
  bool get isFeatured;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreImplCopyWith<_$StoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
