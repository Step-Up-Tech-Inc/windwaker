import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/models/order.dart';
import 'package:windwaker/core/services/order_service.dart';

/// Sección de pago SINPE en el seguimiento del pedido: muestra el número
/// del negocio y el monto, y permite subir el comprobante de la
/// transferencia (que el negocio verificará contra su cuenta).
class SinpePaymentSection extends StatelessWidget {
  final Order order;

  const SinpePaymentSection({super.key, required this.order});

  Future<void> _copyNumber(BuildContext context) async {
    final number = order.storeSinpeNumber;
    if (number == null) return;
    await Clipboard.setData(ClipboardData(text: number));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número SINPE copiado.')),
      );
    }
  }

  Future<void> _showUploadSheet(BuildContext context) async {
    final referenceController = TextEditingController();
    XFile? proofImage;

    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        bool sending = false;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Subir comprobante SINPE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: referenceController,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Número de referencia',
                      hintText: 'El que aparece en tu comprobante',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1200,
                        imageQuality: 85,
                      );
                      if (picked != null) {
                        setSheetState(() => proofImage = picked);
                      }
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      proofImage?.name ?? 'Elegir captura del comprobante',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed:
                        sending
                            ? null
                            : () async {
                                final image = proofImage;
                                final reference =
                                    referenceController.text.trim();
                                if (image == null || reference.isEmpty) return;
                                setSheetState(() => sending = true);
                                try {
                                  await getIt<OrderService>()
                                      .submitPaymentProof(
                                        orderId: order.id,
                                        imageBytes: await image.readAsBytes(),
                                        fileName: image.name,
                                        reference: reference,
                                      );
                                  if (sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop(true);
                                  }
                                } catch (_) {
                                  setSheetState(() => sending = false);
                                }
                              },
                    child:
                        sending
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Enviar comprobante'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Comprobante enviado. El negocio lo verificará en breve.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (order.paymentMethod != OrderPaymentMethod.sinpe) {
      return const SizedBox.shrink();
    }

    final currency = NumberFormat.currency(locale: 'es_CR', symbol: '₡');

    final (statusLabel, statusColor, canUpload) = switch (order
        .paymentStatus) {
      PaymentStatus.pending => (
        'Pago pendiente: transfiere y sube tu comprobante',
        Colors.orange,
        true,
      ),
      PaymentStatus.submitted => (
        'Comprobante enviado — en revisión por el negocio',
        Colors.blue,
        false,
      ),
      PaymentStatus.verified => ('Pago verificado ✓', Colors.green, false),
      PaymentStatus.rejected => (
        'Comprobante rechazado — súbelo de nuevo',
        Colors.red,
        true,
      ),
      PaymentStatus.notRequired => ('', Colors.grey, false),
    };
    if (statusLabel.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_iphone, color: statusColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Pago por SINPE Móvil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusLabel,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
          ),
          if (order.storeSinpeNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Transfiere ${currency.format(order.total)} al '
                    '${order.storeSinpeNumber}',
                  ),
                ),
                IconButton(
                  onPressed: () => _copyNumber(context),
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copiar número',
                ),
              ],
            ),
          ],
          if (canUpload) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showUploadSheet(context),
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Subir comprobante'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
