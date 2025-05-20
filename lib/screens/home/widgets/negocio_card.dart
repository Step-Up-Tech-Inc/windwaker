import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/negocio.dart';

class NegocioCard extends StatelessWidget {
  final Negocio negocio;

  const NegocioCard({super.key, required this.negocio});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del negocio
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: negocio.imagenUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del negocio (máximo 2 líneas)
                Text(
                  negocio.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Calificación con estrellas
                Row(
                  children: [
                    _buildRatingStars(negocio.calificacion),
                    const SizedBox(width: 4),
                    Text(
                      negocio.calificacion.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Tiempo de entrega
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${negocio.tiempoEntregaMin}–${negocio.tiempoEntregaMax} min',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Costo de envío
                Row(
                  children: [
                    const Icon(
                      Icons.delivery_dining,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '₡${negocio.costoEnvio.toInt()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 14, color: Colors.amber);
        } else if (index < rating.ceil() &&
            rating.truncateToDouble() != rating) {
          return const Icon(Icons.star_half, size: 14, color: Colors.amber);
        } else {
          return const Icon(Icons.star_border, size: 14, color: Colors.amber);
        }
      }),
    );
  }
}
