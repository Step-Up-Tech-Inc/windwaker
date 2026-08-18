import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/config/locale_controller.dart';
import 'package:windwaker/core/repositories/user_repository.dart';
import 'package:windwaker/core/services/notification_service.dart';
import 'package:windwaker/core/services/preferences_service.dart';
import 'package:windwaker/core/services/profile_validation_service.dart';
import 'package:windwaker/screens/search/widgets/bottom_navigation.dart';

/// Pantalla de perfil del usuario (estilo lista de opciones).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _logger = Logger();
  late final ProfileValidationService _profileValidationService;

  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profileValidationService = getIt<ProfileValidationService>();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() => _isLoading = true);
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'No hay usuario autenticado';
          _isLoading = false;
        });
        return;
      }
      final profileData = await _profileValidationService.getUserProfileData(
        currentUser.id,
      );
      if (mounted) {
        setState(() {
          _profileData = profileData;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error cargando datos del perfil: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error cargando perfil: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/auth');
    } catch (e) {
      _logger.e('Error al cerrar sesión: $e');
    }
  }

  /// Diálogo de notificaciones: activar/desactivar push.
  Future<void> _showNotificationsDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final notifications = getIt<NotificationService>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.notifications),
              content: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  notifications.enabled
                      ? l10n.notificationsEnabled
                      : l10n.notificationsDisabled,
                ),
                subtitle: Text(l10n.notificationsDescription),
                value: notifications.enabled,
                onChanged: (value) async {
                  await notifications.setEnabled(value);
                  setDialogState(() {});
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  /// Diálogo de método de pago preferido (efectivo / SINPE Móvil).
  Future<void> _showPaymentDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final preferences = getIt<PreferencesService>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.paymentMethods),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.preferredPaymentDescription,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.cash),
                    secondary: const Icon(Icons.payments_outlined),
                    value: 'cash',
                    groupValue: preferences.preferredPaymentMethod,
                    onChanged: (value) async {
                      await preferences.setPreferredPaymentMethod(value!);
                      setDialogState(() {});
                    },
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.sinpe),
                    secondary: const Icon(Icons.phone_iphone),
                    value: 'sinpe',
                    groupValue: preferences.preferredPaymentMethod,
                    onChanged: (value) async {
                      await preferences.setPreferredPaymentMethod(value!);
                      setDialogState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  /// Diálogo de idioma (español / inglés).
  Future<void> _showLanguageDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final localeController = getIt<LocaleController>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in const [('es', 'Español'), ('en', 'English')])
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.$2),
                  value: option.$1,
                  groupValue: localeController.value.languageCode,
                  onChanged: (value) async {
                    await localeController.setLanguage(value!);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
    if (mounted) setState(() {});
  }

  /// Edición del perfil: nombre y foto.
  Future<void> _showEditDialog() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await showDialog<void>(
      context: context,
      builder:
          (_) => _EditProfileDialog(
            userId: user.id,
            initialName: (_profileData?['full_name'] as String?) ?? '',
          ),
    );
    await _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.myProfile,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          tooltip: 'Volver',
          onPressed: () => context.go('/home'),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;
    final avatarUrl = _profileData?['avatar_url'] as String?;
    final fullName = _profileData?['full_name'] as String?;

    return ListView(
      children: [
        // ── Encabezado ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Row(
            children: [
              GestureDetector(
                onTap: _showEditDialog,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF2979FF),
                      backgroundImage:
                          (avatarUrl?.isNotEmpty ?? false)
                              ? NetworkImage(avatarUrl!)
                              : null,
                      child:
                          (avatarUrl?.isNotEmpty ?? false)
                              ? null
                              : const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2979FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_camera,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (fullName?.isNotEmpty ?? false)
                          ? fullName!
                          : l10n.defaultUserName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profileData?['phone'] ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      _profileData?['email'] ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Grupo 1 ──
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.person,
              color: const Color(0xFF2979FF),
              title: l10n.personalInfo,
              onTap: _showEditDialog,
            ),
            _MenuItem(
              icon: Icons.place,
              color: const Color(0xFF7C4DFF),
              title: l10n.savedAddresses,
              onTap: () => context.go('/addresses'),
            ),
            _MenuItem(
              icon: Icons.payment,
              color: const Color(0xFF00C853),
              title: l10n.paymentMethods,
              trailingText:
                  getIt<PreferencesService>().preferredPaymentMethod == 'cash'
                      ? l10n.cash
                      : l10n.sinpe,
              onTap: _showPaymentDialog,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Grupo 2 ──
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.history,
              color: const Color(0xFFFF9100),
              title: l10n.orderHistory,
              onTap: () => context.go('/order-history'),
            ),
            _MenuItem(
              icon: Icons.notifications,
              color: const Color(0xFFFF5252),
              title: l10n.notifications,
              trailingText:
                  getIt<NotificationService>().enabled
                      ? l10n.notificationsEnabled
                      : l10n.notificationsDisabled,
              onTap: _showNotificationsDialog,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Grupo 3 ──
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.language,
              color: const Color(0xFF00BFA5),
              title: l10n.language,
              trailingText:
                  getIt<LocaleController>().value.languageCode == 'es'
                      ? 'Español'
                      : 'English',
              onTap: _showLanguageDialog,
            ),
            _MenuItem(
              icon: Icons.support_agent,
              color: const Color(0xFF536DFE),
              title: l10n.helpSupport,
              onTap: () => context.go('/help'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Cerrar sesión ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton(
            onPressed: _signOut,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFEBEE),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.signOut,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Diálogo de edición de perfil. Es un StatefulWidget para que el framework
/// libere el TextEditingController DESPUÉS de que el diálogo salga del árbol
/// (hacer dispose manual durante la animación de cierre crashea).
class _EditProfileDialog extends StatefulWidget {
  final String userId;
  final String initialName;

  const _EditProfileDialog({required this.userId, required this.initialName});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialName,
  );
  final _logger = Logger();
  XFile? _pickedImage;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      setState(() => _pickedImage = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final userRepository = getIt<UserRepository>();
      String? avatarUrl;
      final image = _pickedImage;
      if (image != null) {
        avatarUrl = await userRepository.uploadAvatar(
          userId: widget.userId,
          fileName: image.name,
          bytes: await image.readAsBytes(),
        );
      }
      await userRepository.updateProfileDetails(
        userId: widget.userId,
        fullName: _nameController.text.trim(),
        avatarUrl: avatarUrl,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _logger.e('Error guardando perfil: $e');
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Información personal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(
              _pickedImage?.name ?? 'Cambiar foto de perfil',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child:
              _saving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Guardar'),
        ),
      ],
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(children: items),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withAlpha(30),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText!,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
