import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../services/currency_service.dart';
import '../services/stream_service.dart';

/// Pantalla principal (Dashboard)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _dbHelper = DatabaseHelper.instance;
  final _currencyService = CurrencyService.instance;
  final _streamService = StreamService.instance;
  String _userName = 'Usuario';
  bool _isLoading = true;

  // Estadísticas
  int _ventasHoy = 0;
  double _ingresosHoy = 0.0;
  int _totalProductos = 0;
  int _productosStockBajo = 0;

  // Cotización del dólar
  double? _exchangeRate;
  bool _loadingRate = false;
  String? _rateError;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadStats();
    _loadExchangeRate();
    _streamService.initialize();
  }

  Future<void> _loadUserName() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.nombre;
      });
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      // Obtener todas las ventas
      final allVentas = await _dbHelper.getAllVentas();

      // Filtrar ventas de hoy
      final today = DateTime.now();
      final ventasHoy = allVentas.where((venta) {
        return venta.fecha.year == today.year &&
            venta.fecha.month == today.month &&
            venta.fecha.day == today.day;
      }).toList();

      // Calcular ingresos de hoy
      final ingresosHoy = ventasHoy.fold<double>(
        0.0,
        (sum, venta) => sum + venta.total,
      );

      // Obtener todos los productos
      final productos = await _dbHelper.getAllProductos();

      // Obtener productos con stock bajo (menos de 10)
      final productosStockBajo = await _dbHelper.getProductosLowStock(10);

      setState(() {
        _ventasHoy = ventasHoy.length;
        _ingresosHoy = ingresosHoy;
        _totalProductos = productos.length;
        _productosStockBajo = productosStockBajo.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estadísticas: $e')),
        );
      }
    }
  }

  Future<void> _loadExchangeRate() async {
    setState(() => _loadingRate = true);
    try {
      final result = await _currencyService.getExchangeRate();
      if (result['success']) {
        setState(() {
          _exchangeRate = result['rate'];
          _loadingRate = false;
          _rateError = null;
        });
      } else {
        setState(() {
          _loadingRate = false;
          _rateError = result['error'];
        });
      }
    } catch (e) {
      setState(() {
        _loadingRate = false;
        _rateError = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      name: 'USD',
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de bienvenida
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Bienvenido!',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tarjeta de ingresos de hoy
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ingresos de Hoy',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Text(
                            currencyFormat.format(_ingresosHoy),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '$_ventasHoy ${_ventasHoy == 1 ? "venta realizada" : "ventas realizadas"}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Estadísticas
                Text('Resumen General', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.shopping_cart,
                          label: 'Ventas Hoy',
                          value: '$_ventasHoy',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.inventory_2,
                          label: 'Productos',
                          value: '$_totalProductos',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.warning_amber,
                          label: 'Stock Bajo',
                          value: '$_productosStockBajo',
                          color: _productosStockBajo > 0
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Tarjeta de cotización del dólar
                Card(
                  elevation: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade300,
                          Colors.purple.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cotización EUR → USD',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              if (_loadingRate)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              else if (_rateError != null)
                                Text(
                                  'No disponible',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                )
                              else if (_exchangeRate != null)
                                Text(
                                  '€1 = \$${_exchangeRate!.toStringAsFixed(4)} USD',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: _loadExchangeRate,
                          tooltip: 'Actualizar',
                        ),
                      ],
                    ),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
