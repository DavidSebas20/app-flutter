import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Servicio de autenticación
/// Gestiona login, registro, persistencia de sesión y cierre de sesión
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Keys para SharedPreferences
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsersDatabase = 'users_database';

  User? _currentUser;

  /// Obtiene el usuario actual
  User? get currentUser => _currentUser;

  /// Verifica si hay una sesión activa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Obtiene el usuario de la sesión actual
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyCurrentUser);

    if (userJson != null) {
      try {
        _currentUser = User.fromJsonString(userJson);
        return _currentUser;
      } catch (e) {
        // Si hay error al parsear, limpiar sesión
        await _clearSession();
        return null;
      }
    }
    return null;
  }

  /// Limpia la sesión interna
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyCurrentUser);
    _currentUser = null;
  }

  /// Registra un nuevo usuario
  Future<User?> register({
    required String nombre,
    required String email,
    required String password,
    String telefono = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obtener base de datos de usuarios
      final usersDbJson = prefs.getString(_keyUsersDatabase);
      Map<String, dynamic> usersDb = {};

      if (usersDbJson != null && usersDbJson.isNotEmpty) {
        try {
          usersDb = jsonDecode(usersDbJson) as Map<String, dynamic>;
        } catch (e) {
          usersDb = {};
        }
      }

      // Verificar si el email ya existe
      final emailKey = email.toLowerCase();
      if (usersDb.containsKey(emailKey)) {
        return null; // Email ya registrado
      }

      // Crear nuevo usuario
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        email: email,
        telefono: telefono,
      );

      // Guardar usuario en la base de datos local
      usersDb[emailKey] = {
        'user': newUser.toJson(),
        'password': password, // En producción esto debería estar hasheado
      };

      await prefs.setString(_keyUsersDatabase, jsonEncode(usersDb));

      // Auto-login después del registro
      return await login(email: email, password: password);
    } catch (e) {
      return null;
    }
  }

  /// Inicia sesión con email y password
  Future<User?> login({required String email, required String password}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Usuario demo para pruebas (siempre disponible)
      if (email.toLowerCase() == 'demo@empresa.com' && password == '123456') {
        final user = User(
          id: 'demo-001',
          nombre: 'Usuario Demo',
          email: email,
          telefono: '+52 55 1234 5678',
        );

        // Guardar sesión
        _currentUser = user;
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyCurrentUser, user.toJsonString());

        return user;
      }

      // Verificar en base de datos local
      final usersDbJson = prefs.getString(_keyUsersDatabase);
      if (usersDbJson != null && usersDbJson.isNotEmpty) {
        try {
          final usersDb = jsonDecode(usersDbJson) as Map<String, dynamic>;
          final emailKey = email.toLowerCase();

          if (usersDb.containsKey(emailKey)) {
            final userData = usersDb[emailKey] as Map<String, dynamic>;
            final storedPassword = userData['password'] as String;

            if (storedPassword == password) {
              final user = User.fromJson(
                userData['user'] as Map<String, dynamic>,
              );

              // Guardar sesión
              _currentUser = user;
              await prefs.setBool(_keyIsLoggedIn, true);
              await prefs.setString(_keyCurrentUser, user.toJsonString());

              return user;
            }
          }
        } catch (e) {
          // Error al parsear base de datos
        }
      }

      return null; // Credenciales incorrectas
    } catch (e) {
      return null;
    }
  }

  /// Cierra la sesión actual
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyCurrentUser);
      _currentUser = null;
    } catch (e) {
      // Error al cerrar sesión
    }
  }

  /// Actualiza el perfil del usuario actual
  Future<bool> updateProfile({
    String? nombre,
    String? telefono,
    String? email,
  }) async {
    try {
      if (_currentUser == null) return false;

      final prefs = await SharedPreferences.getInstance();

      // Actualizar datos del usuario
      _currentUser = _currentUser!.copyWith(
        nombre: nombre ?? _currentUser!.nombre,
        telefono: telefono ?? _currentUser!.telefono,
        email: email ?? _currentUser!.email,
      );

      // Guardar cambios en sesión
      await prefs.setString(_keyCurrentUser, _currentUser!.toJsonString());

      // Actualizar en la base de datos local si no es usuario demo
      if (_currentUser!.id != 'demo-001') {
        final usersDbJson = prefs.getString(_keyUsersDatabase);
        if (usersDbJson != null && usersDbJson.isNotEmpty) {
          try {
            final usersDb = jsonDecode(usersDbJson) as Map<String, dynamic>;
            final oldEmail = _currentUser!.email.toLowerCase();

            if (usersDb.containsKey(oldEmail)) {
              final userData = usersDb[oldEmail] as Map<String, dynamic>;
              userData['user'] = _currentUser!.toJson();

              // Si cambió el email, mover la entrada
              if (email != null && email.toLowerCase() != oldEmail) {
                usersDb.remove(oldEmail);
                usersDb[email.toLowerCase()] = userData;
              }

              await prefs.setString(_keyUsersDatabase, jsonEncode(usersDb));
            }
          } catch (e) {
            // Error al actualizar base de datos
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cambia la contraseña del usuario actual
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) return false;
      if (_currentUser!.id == 'demo-001')
        return false; // No permitir cambiar contraseña demo

      final prefs = await SharedPreferences.getInstance();
      final usersDbJson = prefs.getString(_keyUsersDatabase);

      if (usersDbJson != null && usersDbJson.isNotEmpty) {
        try {
          final usersDb = jsonDecode(usersDbJson) as Map<String, dynamic>;
          final emailKey = _currentUser!.email.toLowerCase();

          if (usersDb.containsKey(emailKey)) {
            final userData = usersDb[emailKey] as Map<String, dynamic>;
            final storedPassword = userData['password'] as String;

            // Verificar contraseña actual
            if (storedPassword == currentPassword) {
              // Actualizar contraseña
              userData['password'] = newPassword;
              await prefs.setString(_keyUsersDatabase, jsonEncode(usersDb));
              return true;
            }
          }
        } catch (e) {
          // Error al procesar
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Limpia todos los datos de autenticación (útil para desarrollo/pruebas)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _currentUser = null;
    } catch (e) {
      // Error al limpiar datos
    }
  }
}
