import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Ayuda y soporte: búsqueda, contacto y preguntas frecuentes.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _query = '';

  static const List<({String question, String answer})> _faqs = [
    (
      question: '¿Cómo hago un pedido?',
      answer:
          'Elige una tienda desde el inicio o la búsqueda, agrega los '
          'productos al carrito y confirma en el checkout con tu dirección '
          'y método de pago. El negocio recibirá tu pedido al instante.',
    ),
    (
      question: '¿Cómo reporto un problema con mi pedido?',
      answer:
          'Desde "Mis pedidos" abre el pedido y usa el seguimiento para ver '
          'su estado. Si algo salió mal (producto faltante o incorrecto), '
          'contáctanos por las opciones de soporte de esta pantalla.',
    ),
    (
      question: '¿Cómo funciona el sistema de envío?',
      answer:
          'Cuando el negocio marca tu pedido como listo, un repartidor de '
          'Tilarán lo recoge y te lo lleva a las señas que indicaste. Puedes '
          'seguir cada paso en tiempo real desde la app.',
    ),
    (
      question: '¿Qué métodos de pago aceptan?',
      answer:
          'Por ahora puedes pagar en efectivo al recibir tu pedido o por '
          'SINPE Móvil. El pago con tarjeta estará disponible más adelante.',
    ),
    (
      question: '¿Puedo cancelar un pedido?',
      answer:
          'Sí, mientras el negocio no lo haya aceptado. Entra al seguimiento '
          'del pedido y usa la opción de cancelar. Una vez aceptado, '
          'comunícate con el negocio o con soporte.',
    ),
    (
      question: 'Políticas de reembolso',
      answer:
          'Si tu pedido llegó incompleto o en mal estado, repórtalo dentro '
          'de las 24 horas. Coordinaremos con el negocio la reposición o la '
          'devolución del dinero según el caso.',
    ),
    (
      question: '¿Cómo registro mi negocio?',
      answer:
          'Crea tu cuenta normal y escríbenos por soporte para activarte '
          'como negocio. Después podrás crear tu tienda, subir tu menú con '
          'fotos y recibir pedidos en tiempo real.',
    ),
    (
      question: '¿Cómo puedo ser repartidor?',
      answer:
          'Regístrate en la app y contáctanos por soporte para activar tu '
          'perfil de repartidor. Verás los pedidos listos para entregar y '
          'ganarás la tarifa de envío de cada entrega.',
    ),
  ];

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature estará disponible próximamente.')),
    );
  }

  /// Formulario para reportar un problema: guarda un ticket en Supabase.
  Future<void> _showReportForm(String type, String title) async {
    final controller = TextEditingController();

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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    maxLength: 2000,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Describe el problema',
                      border: OutlineInputBorder(),
                      hintText:
                          'Cuéntanos qué pasó con el mayor detalle posible…',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed:
                        sending
                            ? null
                            : () async {
                                final message = controller.text.trim();
                                if (message.isEmpty) return;
                                setSheetState(() => sending = true);
                                try {
                                  final supabase = Supabase.instance.client;
                                  await supabase
                                      .from('support_tickets')
                                      .insert({
                                        'user_id':
                                            supabase.auth.currentUser!.id,
                                        'type': type,
                                        'message': message,
                                      });
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
                            : const Text('Enviar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu reporte fue enviado. Te contactaremos pronto.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final faqs =
        _query.isEmpty
            ? _faqs
            : _faqs
                .where(
                  (f) =>
                      f.question.toLowerCase().contains(_query.toLowerCase()) ||
                      f.answer.toLowerCase().contains(_query.toLowerCase()),
                )
                .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Ayuda y Soporte',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          tooltip: 'Volver',
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Buscador ──
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Buscar ayuda',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Contacto ──
          Row(
            children: [
              _SupportCard(
                icon: Icons.chat_bubble_outline,
                iconColor: const Color(0xFF2979FF),
                title: 'Chat con Soporte',
                subtitle: 'Tiempo de respuesta: 5 min',
                onTap: () => _comingSoon('El chat de soporte'),
              ),
              const SizedBox(width: 12),
              _SupportCard(
                icon: Icons.phone,
                iconColor: const Color(0xFF00C853),
                title: 'Llamar a Soporte',
                subtitle: 'Lun-Vie 8AM-6PM',
                onTap: () => _comingSoon('La línea de soporte'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── FAQ ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'Preguntas Frecuentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (faqs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No encontramos resultados para tu búsqueda.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  for (final faq in faqs)
                    ExpansionTile(
                      title: Text(
                        faq.question,
                        style: const TextStyle(fontSize: 15),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      children: [
                        Text(
                          faq.answer,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Reportar un problema ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reportar un Problema',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _ReportItem(
                  icon: Icons.error_outline,
                  color: const Color(0xFFFF5252),
                  title: 'Problema con el pedido',
                  subtitle: 'Reportar problemas con tu entrega',
                  onTap:
                      () => _showReportForm('order', 'Problema con el pedido'),
                ),
                _ReportItem(
                  icon: Icons.storefront_outlined,
                  color: const Color(0xFFFF9100),
                  title: 'Problema con la tienda',
                  subtitle: 'Reportar problemas con un negocio',
                  onTap:
                      () => _showReportForm('store', 'Problema con la tienda'),
                ),
                _ReportItem(
                  icon: Icons.bug_report_outlined,
                  color: const Color(0xFF7C4DFF),
                  title: 'Problema con la app',
                  subtitle: 'Reportar errores de la aplicación',
                  onTap: () => _showReportForm('app', 'Problema con la app'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: iconColor.withAlpha(30),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReportItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(30),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
