import 'package:flutter/material.dart';

/// Pantalla de perfil de usuario
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Text('Usuario Demo', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('usuario@empresa.com', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)),
              const SizedBox(height: 32),

              // Opciones de perfil
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                      title: const Text('Editar Perfil'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función en desarrollo')),
                        );
                      },
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      leading: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                      title: const Text('Cambiar Contraseña'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función en desarrollo')),
                        );
                      },
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      leading: Icon(Icons.notifications, color: theme.colorScheme.primary),
                      title: const Text('Notificaciones'),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      leading: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                      title: const Text('Modo Oscuro'),
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {},
                      ),
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
                      leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      title: const Text('Acerca de'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Distribuidora Oficina',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(Icons.inventory_2, size: 48, color: theme.colorScheme.primary),
                          children: [
                            const Text('Sistema de Gestión de Ventas para distribución de productos de oficina.'),
                          ],
                        );
                      },
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      leading: Icon(Icons.help_outline, color: theme.colorScheme.primary),
                      title: const Text('Ayuda'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función en desarrollo')),
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
                        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/login');
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
