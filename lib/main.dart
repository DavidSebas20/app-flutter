import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'services/permissions_service.dart';

/// Punto de entrada de la aplicación
/// Distribuidora de Productos de Oficina - Sistema de Gestión de Ventas
void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Verificar permisos básicos
  final permissionsService = PermissionsService();
  await permissionsService.requestStoragePermission();

  runApp(const MainApp());
}

/// Widget raíz de la aplicación
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Configuración general
      title: 'Distribuidora Oficina',
      debugShowCheckedModeBanner: false,

      // Tema de la aplicación
      theme: AppTheme.lightTheme,

      // Pantalla inicial con verificación de sesión
      home: const SplashScreen(),

      // Rutas de navegación
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

/// Splash Screen que verifica la sesión al iniciar
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  /// Verifica si hay una sesión activa
  Future<void> _checkSession() async {
    // Esperar un momento para mostrar splash
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Hay sesión activa, ir al main
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // No hay sesión, ir al login
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icono
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Nombre de la app
            const Text(
              'Distribuidora Oficina',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            // Subtítulo
            const Text(
              'Sistema de Gestión de Ventas',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),

            // Indicador de carga
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
