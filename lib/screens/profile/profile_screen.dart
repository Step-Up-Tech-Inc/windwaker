import 'package:flutter/material.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService _authService;
  String? _email;
  String? _phone;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    _email = _authService.getUserEmail();
    _phone = _authService.getUserPhone();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    await _authService.signOut();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _signOut,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    if (_email != null && _email!.isNotEmpty)
                      _buildInfoCard(
                        title: 'Correo electrónico',
                        value: _email!,
                        icon: Icons.email,
                      ),
                    if (_phone != null && _phone!.isNotEmpty)
                      _buildInfoCard(
                        title: 'Teléfono',
                        value: _phone!,
                        icon: Icons.phone,
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Aquí podrías navegar a una pantalla de edición de perfil
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función no implementada aún'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Editar perfil'),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
