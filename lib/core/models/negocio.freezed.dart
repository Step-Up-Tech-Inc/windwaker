// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'negocio.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Negocio _$NegocioFromJson(Map<String, dynamic> json) {
  return _Negocio.fromJson(json);
}

/// @nodoc
mixin _$Negocio {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get imagenUrl => throw _privateConstructorUsedError;
  double get calificacion => throw _privateConstructorUsedError;
  int get tiempoEntregaMin => throw _privateConstructorUsedError;
  int get tiempoEntregaMax => throw _privateConstructorUsedError;
  double get costoEnvio => throw _privateConstructorUsedError;
  String get categoria => throw _privateConstructorUsedError;
  String get ciudad => throw _privateConstructorUsedError;
  bool get esDestacado => throw _privateConstructorUsedError;
  bool get activo => throw _privateConstructorUsedError;

  /// Serializes this Negocio to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Negocio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NegocioCopyWith<Negocio> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NegocioCopyWith<$Res> {
  factory $NegocioCopyWith(Negocio value, $Res Function(Negocio) then) =
      _$NegocioCopyWithImpl<$Res, Negocio>;
  @useResult
  $Res call({
    String id,
    String nombre,
    String imagenUrl,
    double calificacion,
    int tiempoEntregaMin,
    int tiempoEntregaMax,
    double costoEnvio,
    String categoria,
    String ciudad,
    bool esDestacado,
    bool activo,
  });
}

/// @nodoc
class _$NegocioCopyWithImpl<$Res, $Val extends Negocio>
    implements $NegocioCopyWith<$Res> {
  _$NegocioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Negocio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? imagenUrl = null,
    Object? calificacion = null,
    Object? tiempoEntregaMin = null,
    Object? tiempoEntregaMax = null,
    Object? costoEnvio = null,
    Object? categoria = null,
    Object? ciudad = null,
    Object? esDestacado = null,
    Object? activo = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            nombre:
                null == nombre
                    ? _value.nombre
                    : nombre // ignore: cast_nullable_to_non_nullable
                        as String,
            imagenUrl:
                null == imagenUrl
                    ? _value.imagenUrl
                    : imagenUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            calificacion:
                null == calificacion
                    ? _value.calificacion
                    : calificacion // ignore: cast_nullable_to_non_nullable
                        as double,
            tiempoEntregaMin:
                null == tiempoEntregaMin
                    ? _value.tiempoEntregaMin
                    : tiempoEntregaMin // ignore: cast_nullable_to_non_nullable
                        as int,
            tiempoEntregaMax:
                null == tiempoEntregaMax
                    ? _value.tiempoEntregaMax
                    : tiempoEntregaMax // ignore: cast_nullable_to_non_nullable
                        as int,
            costoEnvio:
                null == costoEnvio
                    ? _value.costoEnvio
                    : costoEnvio // ignore: cast_nullable_to_non_nullable
                        as double,
            categoria:
                null == categoria
                    ? _value.categoria
                    : categoria // ignore: cast_nullable_to_non_nullable
                        as String,
            ciudad:
                null == ciudad
                    ? _value.ciudad
                    : ciudad // ignore: cast_nullable_to_non_nullable
                        as String,
            esDestacado:
                null == esDestacado
                    ? _value.esDestacado
                    : esDestacado // ignore: cast_nullable_to_non_nullable
                        as bool,
            activo:
                null == activo
                    ? _value.activo
                    : activo // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NegocioImplCopyWith<$Res> implements $NegocioCopyWith<$Res> {
  factory _$$NegocioImplCopyWith(
    _$NegocioImpl value,
    $Res Function(_$NegocioImpl) then,
  ) = __$$NegocioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nombre,
    String imagenUrl,
    double calificacion,
    int tiempoEntregaMin,
    int tiempoEntregaMax,
    double costoEnvio,
    String categoria,
    String ciudad,
    bool esDestacado,
    bool activo,
  });
}

/// @nodoc
class __$$NegocioImplCopyWithImpl<$Res>
    extends _$NegocioCopyWithImpl<$Res, _$NegocioImpl>
    implements _$$NegocioImplCopyWith<$Res> {
  __$$NegocioImplCopyWithImpl(
    _$NegocioImpl _value,
    $Res Function(_$NegocioImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Negocio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? imagenUrl = null,
    Object? calificacion = null,
    Object? tiempoEntregaMin = null,
    Object? tiempoEntregaMax = null,
    Object? costoEnvio = null,
    Object? categoria = null,
    Object? ciudad = null,
    Object? esDestacado = null,
    Object? activo = null,
  }) {
    return _then(
      _$NegocioImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        nombre:
            null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                    as String,
        imagenUrl:
            null == imagenUrl
                ? _value.imagenUrl
                : imagenUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        calificacion:
            null == calificacion
                ? _value.calificacion
                : calificacion // ignore: cast_nullable_to_non_nullable
                    as double,
        tiempoEntregaMin:
            null == tiempoEntregaMin
                ? _value.tiempoEntregaMin
                : tiempoEntregaMin // ignore: cast_nullable_to_non_nullable
                    as int,
        tiempoEntregaMax:
            null == tiempoEntregaMax
                ? _value.tiempoEntregaMax
                : tiempoEntregaMax // ignore: cast_nullable_to_non_nullable
                    as int,
        costoEnvio:
            null == costoEnvio
                ? _value.costoEnvio
                : costoEnvio // ignore: cast_nullable_to_non_nullable
                    as double,
        categoria:
            null == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                    as String,
        ciudad:
            null == ciudad
                ? _value.ciudad
                : ciudad // ignore: cast_nullable_to_non_nullable
                    as String,
        esDestacado:
            null == esDestacado
                ? _value.esDestacado
                : esDestacado // ignore: cast_nullable_to_non_nullable
                    as bool,
        activo:
            null == activo
                ? _value.activo
                : activo // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NegocioImpl implements _Negocio {
  const _$NegocioImpl({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.calificacion,
    required this.tiempoEntregaMin,
    required this.tiempoEntregaMax,
    required this.costoEnvio,
    required this.categoria,
    required this.ciudad,
    this.esDestacado = false,
    required this.activo,
  });

  factory _$NegocioImpl.fromJson(Map<String, dynamic> json) =>
      _$$NegocioImplFromJson(json);

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String imagenUrl;
  @override
  final double calificacion;
  @override
  final int tiempoEntregaMin;
  @override
  final int tiempoEntregaMax;
  @override
  final double costoEnvio;
  @override
  final String categoria;
  @override
  final String ciudad;
  @override
  @JsonKey()
  final bool esDestacado;
  @override
  final bool activo;

  @override
  String toString() {
    return 'Negocio(id: $id, nombre: $nombre, imagenUrl: $imagenUrl, calificacion: $calificacion, tiempoEntregaMin: $tiempoEntregaMin, tiempoEntregaMax: $tiempoEntregaMax, costoEnvio: $costoEnvio, categoria: $categoria, ciudad: $ciudad, esDestacado: $esDestacado, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NegocioImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.imagenUrl, imagenUrl) ||
                other.imagenUrl == imagenUrl) &&
            (identical(other.calificacion, calificacion) ||
                other.calificacion == calificacion) &&
            (identical(other.tiempoEntregaMin, tiempoEntregaMin) ||
                other.tiempoEntregaMin == tiempoEntregaMin) &&
            (identical(other.tiempoEntregaMax, tiempoEntregaMax) ||
                other.tiempoEntregaMax == tiempoEntregaMax) &&
            (identical(other.costoEnvio, costoEnvio) ||
                other.costoEnvio == costoEnvio) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.ciudad, ciudad) || other.ciudad == ciudad) &&
            (identical(other.esDestacado, esDestacado) ||
                other.esDestacado == esDestacado) &&
            (identical(other.activo, activo) || other.activo == activo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nombre,
    imagenUrl,
    calificacion,
    tiempoEntregaMin,
    tiempoEntregaMax,
    costoEnvio,
    categoria,
    ciudad,
    esDestacado,
    activo,
  );

  /// Create a copy of Negocio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NegocioImplCopyWith<_$NegocioImpl> get copyWith =>
      __$$NegocioImplCopyWithImpl<_$NegocioImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NegocioImplToJson(this);
  }
}

abstract class _Negocio implements Negocio {
  const factory _Negocio({
    required final String id,
    required final String nombre,
    required final String imagenUrl,
    required final double calificacion,
    required final int tiempoEntregaMin,
    required final int tiempoEntregaMax,
    required final double costoEnvio,
    required final String categoria,
    required final String ciudad,
    final bool esDestacado,
    required final bool activo,
  }) = _$NegocioImpl;

  factory _Negocio.fromJson(Map<String, dynamic> json) = _$NegocioImpl.fromJson;

  @override
  String get id;
  @override
  String get nombre;
  @override
  String get imagenUrl;
  @override
  double get calificacion;
  @override
  int get tiempoEntregaMin;
  @override
  int get tiempoEntregaMax;
  @override
  double get costoEnvio;
  @override
  String get categoria;
  @override
  String get ciudad;
  @override
  bool get esDestacado;
  @override
  bool get activo;

  /// Create a copy of Negocio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NegocioImplCopyWith<_$NegocioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
