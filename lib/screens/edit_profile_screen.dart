import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

/// Pantalla de edición de perfil de usuario
/// Permite actualizar nombre, email y teléfono
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = true;
  bool _isSaving = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga los datos del usuario actual
  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
        _nameController.text = user.nombre;
        _emailController.text = user.email;
        _phoneController.text = user.telefono;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Guarda los cambios del perfil
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final success = await _authService.updateProfile(
          nombre: _nameController.text.trim(),
          email: _emailController.text.trim(),
          telefono: _phoneController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isSaving = false;
          });

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Retornar true para indicar cambios
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al actualizar perfil'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar cambios'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          if (!_isLoading && !_isSaving)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Guardar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Información de usuario
                      if (_currentUser != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Información Personal',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),

                                // Campo de nombre
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre completo',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese su nombre';
                                    }
                                    if (value.length < 3) {
                                      return 'El nombre debe tener al menos 3 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Campo de email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Correo electrónico',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese su correo';
                                    }
                                    if (!value.contains('@') ||
                                        !value.contains('.')) {
                                      return 'Ingrese un correo válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Campo de teléfono
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Teléfono',
                                    hintText: '+52 55 1234 5678',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Información adicional
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información de Cuenta',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                leading: Icon(
                                  Icons.badge_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                title: const Text('ID de Usuario'),
                                subtitle: Text(_currentUser?.id ?? 'N/A'),
                              ),
                              const Divider(),
                              ListTile(
                                leading: Icon(
                                  Icons.lock_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                title: const Text('Cambiar Contraseña'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // TODO: Navegar a cambiar contraseña
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
                      ),
                      const SizedBox(height: 24),

                      // Botón de guardar
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Guardar Cambios'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
