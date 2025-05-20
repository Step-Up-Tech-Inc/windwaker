// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'negocio.freezed.dart';
part 'negocio.g.dart';

@freezed
class Negocio with _$Negocio {
  const factory Negocio({
    required String id,
    required String nombre,
    required String imagenUrl,
    required double calificacion,
    required int tiempoEntregaMin,
    required int tiempoEntregaMax,
    required double costoEnvio,
    required String categoria,
    required String ciudad,
    required bool activo,
  }) = _Negocio;

  factory Negocio.fromJson(Map<String, dynamic> json) =>
      _$NegocioFromJson(json);
}
