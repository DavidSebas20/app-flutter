import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'edit_profile_screen.dart';

/// Pantalla de perfil de usuario
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga los datos del usuario actual
  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  /// Navega a la edición de perfil
  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    // Si se guardaron cambios, recargar datos
    if (result == true) {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Avatar y nombre
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                _currentUser?.nombre ?? 'Usuario',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _currentUser?.email ?? 'email@empresa.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              if (_currentUser?.telefono.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentUser!.telefono,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),

              // Opciones de perfil
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Editar Perfil'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _navigateToEditProfile,
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      leading: Icon(
                        Icons.lock_outline,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Cambiar Contraseña'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función en desarrollo'),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Notificaciones'),
                      trailing: Switch(value: true, onChanged: (value) {}),
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      leading: Icon(
                        Icons.dark_mode_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Modo Oscuro'),
                      trailing: Switch(value: false, onChanged: (value) {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Información de la app
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Acerca de'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Distribuidora Oficina',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(
                            Icons.inventory_2,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          children: const [
                            Text(
                              'Sistema de Gestión de Ventas para distribución de productos de oficina.',
                            ),
                          ],
                        );
                      },
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Ayuda'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función en desarrollo'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón de cerrar sesión
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text(
                          '¿Estás seguro que deseas cerrar sesión?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              // Cerrar sesión
                              await _authService.logout();
                              if (context.mounted) {
                                Navigator.pop(context); // Cerrar diálogo
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              }
                            },
                            child: const Text('Cerrar Sesión'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
