// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'negocio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NegocioImpl _$$NegocioImplFromJson(Map<String, dynamic> json) =>
    _$NegocioImpl(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      imagenUrl: json['imagen_url'] as String,
      calificacion: (json['calificacion'] as num).toDouble(),
      tiempoEntregaMin: (json['tiempo_entrega_min'] as num).toInt(),
      tiempoEntregaMax: (json['tiempo_entrega_max'] as num).toInt(),
      costoEnvio: (json['costo_envio'] as num).toDouble(),
      categoria: json['categoria'] as String,
      ciudad: json['ciudad'] as String,
      esDestacado: json['es_destacado'] as bool? ?? false,
      activo: json['activo'] as bool,
    );

Map<String, dynamic> _$$NegocioImplToJson(_$NegocioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'imagen_url': instance.imagenUrl,
      'calificacion': instance.calificacion,
      'tiempo_entrega_min': instance.tiempoEntregaMin,
      'tiempo_entrega_max': instance.tiempoEntregaMax,
      'costo_envio': instance.costoEnvio,
      'categoria': instance.categoria,
      'ciudad': instance.ciudad,
      'es_destacado': instance.esDestacado,
      'activo': instance.activo,
    };
