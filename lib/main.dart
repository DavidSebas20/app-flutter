import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';

/// Punto de entrada de la aplicación
/// Distribuidora de Productos de Oficina - Sistema de Gestión de Ventas
void main() {
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

      // Ruta inicial
      initialRoute: '/login',

      // Rutas de navegación
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
