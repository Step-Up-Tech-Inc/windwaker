import 'package:flutter/material.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/core/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService _authService;
  late final UserRepository _userRepository;
  final _logger = Logger();
  String? _email;
  String? _phone;
  bool _isLoading = false;
  String? _diagnosticResult;
  bool _hasSessionError = false;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _userRepository = getIt<UserRepository>();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _hasSessionError = false;
    });

    try {
      // Verificar y refrescar la sesión si es necesario
      final sessionValid = await _authService.verifyAndRefreshSession();

      if (!sessionValid) {
        _logger.w(
          'La sesión no es válida, verificando datos en SharedPreferences',
        );

        // Intentar cargar datos desde SharedPreferences
        final prefs = getIt<SharedPreferences>();
        final email = prefs.getString('user_email');
        final phone = prefs.getString('user_phone');

        if (email != null || phone != null) {
          _logger.i(
            'Datos encontrados en SharedPreferences: email=$email, phone=$phone',
          );
          setState(() {
            _email = email;
            _phone = phone;
            _hasSessionError = false;
            _diagnosticResult =
                'Usando datos de SharedPreferences. La sesión de Supabase no está activa.';
          });
          return;
        }

        if (!mounted) return;

        setState(() {
          _hasSessionError = true;
          _isLoading = false;
        });

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La sesión ha expirado. Usa el botón de emergencia para cerrar sesión.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // Cargar datos del usuario
      _email = _authService.getUserEmail();
      _phone = _authService.getUserPhone();

      _logger.i('Datos de usuario cargados: email=$_email, phone=$_phone');
    } catch (e) {
      _logger.e('Error al cargar datos del usuario: $e');

      // Intentar cargar datos desde SharedPreferences como respaldo
      try {
        final prefs = getIt<SharedPreferences>();
        final email = prefs.getString('user_email');
        final phone = prefs.getString('user_phone');

        if (email != null || phone != null) {
          _logger.i('Usando datos de respaldo: email=$email, phone=$phone');
          setState(() {
            _email = email;
            _phone = phone;
            _hasSessionError = false;
            _diagnosticResult = 'Usando datos de respaldo. Error original: $e';
          });
          return;
        }
      } catch (prefError) {
        _logger.e('Error al cargar datos de respaldo: $prefError');
      }

      // Mostrar mensaje de error
      if (mounted) {
        setState(() {
          _hasSessionError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  void _goToEmergencyLogout() {
    context.go('/emergency-logout');
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isLoading = true;
      _diagnosticResult = null;
    });

    try {
      _logger.i('Ejecutando diagnóstico de tabla profiles...');

      // Verificar si hay un usuario autenticado
      final currentUser = _userRepository.getCurrentUser();
      final prefs = getIt<SharedPreferences>();
      final email = prefs.getString('user_email');
      final phone = prefs.getString('user_phone');

      _logger.i('Datos en SharedPreferences: email=$email, phone=$phone');

      if (currentUser == null) {
        _logger.w('No hay usuario autenticado en Supabase');

        // Verificar si hay información en SharedPreferences
        if (email == null && phone == null) {
          setState(() {
            _diagnosticResult =
                'ERROR: No hay usuario autenticado ni datos en SharedPreferences.\n'
                'Debes iniciar sesión antes de ejecutar el diagnóstico.\n'
                'Intenta cerrar sesión y volver a iniciarla.';
          });
          return;
        }

        _logger.i('Usando datos de SharedPreferences para diagnóstico');
        setState(() {
          _diagnosticResult =
              'No hay usuario autenticado en Supabase, pero hay datos en SharedPreferences:\n'
              'Email: $email\n'
              'Teléfono: $phone\n\n'
              'Intentando buscar perfil por teléfono...';
        });

        // Intentar buscar el perfil por teléfono
        try {
          if (phone != null) {
            final data =
                await Supabase.instance.client
                    .from('profiles')
                    .select('id, email, phone')
                    .eq('phone', phone)
                    .maybeSingle();

            if (data != null) {
              setState(() {
                _diagnosticResult =
                    '$_diagnosticResult\n\nPerfil encontrado: $data';
              });
            } else {
              setState(() {
                _diagnosticResult =
                    '$_diagnosticResult\n\nNo se encontró perfil para el teléfono: $phone';
              });
            }
          }
        } catch (e) {
          setState(() {
            _diagnosticResult =
                '$_diagnosticResult\n\nError al buscar perfil: $e';
          });
        }

        return;
      }

      _logger.i('Usuario autenticado: ${currentUser.id}');

      final result = await _userRepository.verifyProfilesTable();

      setState(() {
        _diagnosticResult = 'Resultado del diagnóstico: ${result.toString()}';
      });

      _logger.i('Diagnóstico completado: $result');

      // Intentar actualizar el perfil del usuario actual
      try {
        // Obtener email y teléfono de SharedPreferences si no están disponibles
        String? userEmail = currentUser.email;
        String? userPhone = currentUser.phone;

        if (userEmail == null || userEmail.isEmpty) {
          userEmail = email;
          _logger.i('Usando email de SharedPreferences: $userEmail');
        }

        if (userPhone == null || userPhone.isEmpty) {
          userPhone = phone;
          _logger.i('Usando teléfono de SharedPreferences: $userPhone');
        }

        await _userRepository.createOrUpdateUserProfile(
          userId: currentUser.id,
          email: userEmail,
          phone: userPhone,
        );
        _logger.i('Perfil actualizado durante diagnóstico');

        // Actualizar el diagnóstico con el resultado
        final updatedProfile = await _userRepository.getUserProfile(
          currentUser.id,
        );
        setState(() {
          _diagnosticResult =
              '$_diagnosticResult\n\nPerfil actualizado: $updatedProfile';
        });
      } catch (e) {
        _logger.e('Error al actualizar perfil durante diagnóstico: $e');
        setState(() {
          _diagnosticResult =
              '$_diagnosticResult\n\nError al actualizar perfil: $e';
        });
      }
    } catch (e) {
      _logger.e('Error al ejecutar diagnóstico: $e');
      setState(() {
        _diagnosticResult = 'Error al ejecutar diagnóstico: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshSession() async {
    setState(() {
      _isLoading = true;
      _diagnosticResult = 'Intentando refrescar la sesión...';
    });

    try {
      // Obtener la sesión actual
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        _logger.w('No hay sesión activa para refrescar');
        setState(() {
          _diagnosticResult =
              'No hay sesión activa para refrescar.\n'
              'Debes iniciar sesión nuevamente.';
          _hasSessionError = true;
        });
        return;
      }

      // Refrescar la sesión
      final response = await Supabase.instance.client.auth.refreshSession();
      if (response.session != null) {
        _logger.i('Sesión refrescada con éxito');

        // Recargar datos del usuario
        await _loadUserData();

        setState(() {
          _diagnosticResult =
              'Sesión refrescada con éxito.\n'
              'Usuario: ${response.user?.id}\n'
              'Email: ${response.user?.email}\n'
              'Teléfono: ${response.user?.phone}';
          _hasSessionError = false;
        });
      } else {
        _logger.w('No se pudo refrescar la sesión');
        setState(() {
          _diagnosticResult =
              'No se pudo refrescar la sesión.\n'
              'Debes iniciar sesión nuevamente.';
          _hasSessionError = true;
        });
      }
    } catch (e) {
      _logger.e('Error al refrescar la sesión: $e');
      setState(() {
        _diagnosticResult = 'Error al refrescar la sesión: $e';
        _hasSessionError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncProfileWithSupabase() async {
    setState(() {
      _isLoading = true;
      _diagnosticResult = 'Sincronizando perfil con Supabase...';
    });

    try {
      final prefs = getIt<SharedPreferences>();
      final email = prefs.getString('user_email');
      final phone = prefs.getString('user_phone');

      if (email == null && phone == null) {
        setState(() {
          _diagnosticResult =
              'No hay datos para sincronizar. Necesitas completar tu perfil primero.';
        });
        return;
      }

      _logger.i('Datos para sincronizar: email=$email, phone=$phone');

      // Verificar si hay un usuario autenticado en Supabase
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser == null) {
        _logger.w('No hay usuario autenticado en Supabase');

        // Intentar buscar el perfil por teléfono
        if (phone != null) {
          try {
            final data =
                await Supabase.instance.client
                    .from('profiles')
                    .select('id, email, phone')
                    .eq('phone', phone)
                    .maybeSingle();

            if (data != null) {
              _logger.i('Perfil encontrado por teléfono: $data');
              setState(() {
                _diagnosticResult =
                    'Encontrado perfil en Supabase por teléfono:\n$data\n\nActualizando...';
              });

              // Actualizar el perfil si el email no coincide
              if (email != null && data['email'] != email) {
                try {
                  final updateSql =
                      "UPDATE profiles SET email = '$email', updated_at = NOW() WHERE id = '${data['id']}';";
                  await Supabase.instance.client.rpc(
                    'exec_sql',
                    params: {'sql': updateSql},
                  );

                  // Verificar actualización
                  final updated =
                      await Supabase.instance.client
                          .from('profiles')
                          .select('id, email, phone')
                          .eq('id', data['id'])
                          .single();

                  setState(() {
                    _diagnosticResult =
                        '$_diagnosticResult\n\nPerfil actualizado:\n$updated';
                  });
                } catch (e) {
                  _logger.e('Error al actualizar perfil: $e');
                  setState(() {
                    _diagnosticResult =
                        '$_diagnosticResult\n\nError al actualizar perfil: $e';
                  });
                }
              } else {
                setState(() {
                  _diagnosticResult =
                      '$_diagnosticResult\n\nEl perfil ya está actualizado.';
                });
              }
            } else {
              _logger.w('No se encontró perfil para el teléfono: $phone');
              setState(() {
                _diagnosticResult =
                    'No se encontró perfil en Supabase para el teléfono: $phone';
              });
            }
          } catch (e) {
            _logger.e('Error al buscar perfil por teléfono: $e');
            setState(() {
              _diagnosticResult = 'Error al buscar perfil por teléfono: $e';
            });
          }
        } else {
          setState(() {
            _diagnosticResult =
                'No hay teléfono para buscar el perfil y no hay usuario autenticado.';
          });
        }
      } else {
        // Hay usuario autenticado, actualizar su perfil
        _logger.i('Usuario autenticado: ${currentUser.id}');

        try {
          // Verificar si el perfil existe
          final profile = await _userRepository.getUserProfile(currentUser.id);

          if (profile == null) {
            _logger.w(
              'No se encontró perfil para el usuario, creando uno nuevo',
            );
            setState(() {
              _diagnosticResult =
                  'No se encontró perfil para el usuario, creando uno nuevo...';
            });

            // Crear perfil con SQL directo
            try {
              final createSql = '''
              INSERT INTO profiles (id, email, phone, created_at, updated_at)
              VALUES ('${currentUser.id}', ${email != null ? "'$email'" : 'NULL'}, ${phone != null ? "'$phone'" : 'NULL'}, NOW(), NOW());
              ''';

              await Supabase.instance.client.rpc(
                'exec_sql',
                params: {'sql': createSql},
              );

              // Verificar creación
              final created = await _userRepository.getUserProfile(
                currentUser.id,
              );

              setState(() {
                _diagnosticResult = 'Perfil creado:\n$created';
              });
            } catch (e) {
              _logger.e('Error al crear perfil: $e');
              setState(() {
                _diagnosticResult = 'Error al crear perfil: $e';
              });
            }
          } else {
            _logger.i('Perfil encontrado: $profile');
            setState(() {
              _diagnosticResult =
                  'Perfil encontrado en Supabase:\n$profile\n\nVerificando si necesita actualización...';
            });

            // Verificar si necesita actualización
            bool needsUpdate = false;

            if (email != null &&
                email.isNotEmpty &&
                profile['email'] != email) {
              _logger.w('Email desactualizado en el perfil');
              needsUpdate = true;
            }

            if (phone != null &&
                phone.isNotEmpty &&
                profile['phone'] != phone) {
              _logger.w('Teléfono desactualizado en el perfil');
              needsUpdate = true;
            }

            if (needsUpdate) {
              _logger.i('El perfil necesita actualización');
              setState(() {
                _diagnosticResult =
                    '$_diagnosticResult\n\nEl perfil necesita actualización. Actualizando...';
              });

              // Actualizar perfil con SQL directo
              try {
                // Construir la parte SET del SQL
                String setSql = "";
                if (email != null) setSql += "email = '$email', ";
                if (phone != null) setSql += "phone = '$phone', ";
                setSql += "updated_at = NOW()";

                final updateSql =
                    "UPDATE profiles SET $setSql WHERE id = '${currentUser.id}';";

                await Supabase.instance.client.rpc(
                  'exec_sql',
                  params: {'sql': updateSql},
                );

                // Verificar actualización
                final updated = await _userRepository.getUserProfile(
                  currentUser.id,
                );

                setState(() {
                  _diagnosticResult =
                      '$_diagnosticResult\n\nPerfil actualizado:\n$updated';
                });
              } catch (e) {
                _logger.e('Error al actualizar perfil: $e');
                setState(() {
                  _diagnosticResult =
                      '$_diagnosticResult\n\nError al actualizar perfil: $e';
                });
              }
            } else {
              _logger.i('El perfil ya está actualizado');
              setState(() {
                _diagnosticResult =
                    '$_diagnosticResult\n\nEl perfil ya está actualizado.';
              });
            }
          }
        } catch (e) {
          _logger.e('Error al verificar/actualizar perfil: $e');
          setState(() {
            _diagnosticResult = 'Error al verificar/actualizar perfil: $e';
          });
        }
      }
    } catch (e) {
      _logger.e('Error general al sincronizar perfil: $e');
      setState(() {
        _diagnosticResult = 'Error general al sincronizar perfil: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasSessionError
              ? _buildSessionErrorView()
              : _buildProfileView(),
    );
  }

  Widget _buildSessionErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error de Sesión',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se ha detectado un problema con tu sesión. Esto puede deberse a que la sesión ha expirado o ha sido invalidada.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('INTENTAR REFRESCAR SESIÓN'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _goToEmergencyLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('IR A CIERRE DE SESIÓN DE EMERGENCIA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          if (_email != null)
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Correo electrónico'),
              subtitle: Text(_email!),
            ),
          if (_phone != null)
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Teléfono'),
              subtitle: Text(_phone!),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
          const SizedBox(height: 32),
          const Text(
            'Herramientas de diagnóstico',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _runDiagnostic,
                  child: const Text('Ejecutar diagnóstico'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _refreshSession,
                  child: const Text('Refrescar sesión'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _syncProfileWithSupabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Sincronizar perfil'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _goToEmergencyLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Cierre de emergencia'),
                ),
              ),
            ],
          ),
          if (_diagnosticResult != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Resultado del diagnóstico:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _diagnosticResult!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
