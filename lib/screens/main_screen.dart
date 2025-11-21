import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'reports_screen.dart';
import 'maps_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import '../services/database_helper.dart';

/// Pantalla principal con navegación por BottomNavigationBar
/// Gestiona la navegación entre las diferentes secciones de la app
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _unreadNotifications = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final lowStockProducts = await _dbHelper.getProductosLowStock(10);
      setState(() {
        _unreadNotifications = lowStockProducts.length;
      });
    } catch (e) {
      setState(() {
        _unreadNotifications = 0;
      });
    }
  }

  // Lista de pantallas principales
  final List<Widget> _screens = const [
    HomeScreen(),
    InventoryScreen(),
    SalesScreen(),
    ReportsScreen(),
    MapsScreen(),
    ProfileScreen(),
  ];

  // Títulos para cada pantalla
  final List<String> _titles = const [
    'Inicio',
    'Inventario',
    'Ventas',
    'Reportes',
    'Mapa',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          // Botón de notificaciones
          IconButton(
            icon: _unreadNotifications > 0
                ? Badge(
                    label: Text('$_unreadNotifications'),
                    child: const Icon(Icons.notifications),
                  )
                : const Icon(Icons.notifications_none),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
              _loadUnreadCount();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
