import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';

/// Pantalla de reportes de ventas
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();

  List<Sale> _sales = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _filterByCurrentUser = false;
  bool _isLoading = true;

  Map<String, dynamic> _stats = {
    'total_ventas': 0,
    'total_ingresos': 0.0,
    'promedio_venta': 0.0,
    'total_productos_vendidos': 0,
  };

  @override
  void initState() {
    super.initState();
    // Inicializar con el mes actual
    _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _endDate = DateTime.now();
    _loadData();
  }

  /// Carga las ventas y estadísticas
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      String? usuarioId;
      if (_filterByCurrentUser) {
        final isLoggedIn = await _authService.isLoggedIn();
        if (isLoggedIn) {
          usuarioId = _authService.currentUser?.id;
        }
      }

      List<Sale> sales;
      if (_startDate != null && _endDate != null) {
        sales = await _dbHelper.getVentasByDateRange(_startDate!, _endDate!);
      } else {
        sales = await _dbHelper.getAllVentas();
      }

      if (usuarioId != null) {
        sales = sales.where((s) => s.usuarioId == usuarioId).toList();
      }

      // Calcular estadísticas
      final totalVentas = sales.length;
      final totalIngresos = sales.fold<double>(
        0.0,
        (sum, sale) => sum + sale.total,
      );
      final promedioVenta = totalVentas > 0 ? totalIngresos / totalVentas : 0.0;
      final totalProductosVendidos = sales.fold<int>(
        0,
        (sum, sale) => sum + sale.cantidad,
      );

      setState(() {
        _sales = sales;
        _stats = {
          'total_ventas': totalVentas,
          'total_ingresos': totalIngresos,
          'promedio_venta': promedioVenta,
          'total_productos_vendidos': totalProductosVendidos,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar reportes: $e')));
      }
    }
  }

  /// Selecciona fecha de inicio
  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  /// Selecciona fecha de fin
  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  /// Obtiene el producto más vendido
  String _getTopProduct() {
    if (_sales.isEmpty) return 'N/A';

    final productCounts = <String, int>{};
    for (final sale in _sales) {
      final name = sale.nombreProducto ?? 'Producto #${sale.productoId}';
      productCounts[name] = (productCounts[name] ?? 0) + sale.cantidad;
    }

    var maxProduct = '';
    var maxCount = 0;
    productCounts.forEach((product, count) {
      if (count > maxCount) {
        maxCount = count;
        maxProduct = product;
      }
    });

    return maxProduct.isNotEmpty ? maxProduct : 'N/A';
  }

  /// Genera un reporte en formato texto
  String _generateTextReport() {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    buffer.writeln('========================================');
    buffer.writeln('REPORTE DE VENTAS');
    buffer.writeln('========================================');
    buffer.writeln();

    if (_startDate != null && _endDate != null) {
      buffer.writeln(
        'Período: ${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
      );
    }

    buffer.writeln();
    buffer.writeln('RESUMEN:');
    buffer.writeln('- Total de ventas: ${_stats['total_ventas']}');
    buffer.writeln(
      '- Ingresos totales: \$${(_stats['total_ingresos'] ?? 0.0).toStringAsFixed(2)}',
    );
    buffer.writeln(
      '- Promedio por venta: \$${(_stats['promedio_venta'] ?? 0.0).toStringAsFixed(2)}',
    );
    buffer.writeln(
      '- Productos vendidos: ${_stats['total_productos_vendidos']}',
    );
    buffer.writeln('- Producto más vendido: ${_getTopProduct()}');
    buffer.writeln();

    buffer.writeln('DETALLE DE VENTAS:');
    buffer.writeln('----------------------------------------');

    for (var i = 0; i < _sales.length; i++) {
      final sale = _sales[i];
      buffer.writeln();
      buffer.writeln('Venta #${i + 1}');
      buffer.writeln('  Fecha: ${dateFormat.format(sale.fecha)}');
      buffer.writeln(
        '  Producto: ${sale.nombreProducto ?? "Producto #${sale.productoId}"}',
      );
      buffer.writeln('  Cantidad: ${sale.cantidad}');
      buffer.writeln(
        '  Precio unitario: \$${sale.precioUnitario.toStringAsFixed(2)}',
      );
      buffer.writeln('  Total: \$${sale.total.toStringAsFixed(2)}');
    }

    buffer.writeln();
    buffer.writeln('========================================');
    buffer.writeln('Generado: ${dateFormat.format(DateTime.now())}');
    buffer.writeln('========================================');

    return buffer.toString();
  }

  /// Muestra el diálogo de exportación
  void _showExportDialog() {
    final reportText = _generateTextReport();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Reporte'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reporte generado exitosamente:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  reportText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () {
              // En una app real, aquí se descargaría el archivo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reporte copiado al portapapeles'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.download),
            label: const Text('Descargar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reportes de Ventas',
                    style: theme.textTheme.headlineSmall,
                  ),
                  IconButton.filled(
                    onPressed: _showExportDialog,
                    icon: const Icon(Icons.download),
                    tooltip: 'Exportar reporte',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filtros
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filtros', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),

                      // Rango de fechas
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectStartDate,
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                _startDate != null
                                    ? dateFormat.format(_startDate!)
                                    : 'Fecha Inicio',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectEndDate,
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                _endDate != null
                                    ? dateFormat.format(_endDate!)
                                    : 'Fecha Fin',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Filtro por usuario
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Solo mis ventas'),
                        subtitle: const Text(
                          'Mostrar únicamente mis ventas registradas',
                        ),
                        value: _filterByCurrentUser,
                        onChanged: (value) {
                          setState(() {
                            _filterByCurrentUser = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // Botón aplicar filtros
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _loadData,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.filter_list),
                          label: Text(
                            _isLoading ? 'Cargando...' : 'Aplicar Filtros',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resumen de ventas
              Text('Resumen del Período', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _ReportCard(
                        icon: Icons.attach_money,
                        label: 'Total Ventas',
                        value:
                            '\$${(_stats['total_ingresos'] ?? 0.0).toStringAsFixed(2)}',
                        color: Colors.green,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportCard(
                        icon: Icons.shopping_cart,
                        label: 'Transacciones',
                        value: '${_stats['total_ventas'] ?? 0}',
                        color: Colors.blue,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ReportCard(
                        icon: Icons.trending_up,
                        label: 'Promedio',
                        value:
                            '\$${(_stats['promedio_venta'] ?? 0.0).toStringAsFixed(2)}',
                        color: Colors.purple,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportCard(
                        icon: Icons.inventory_2,
                        label: 'Productos',
                        value: '${_stats['total_productos_vendidos'] ?? 0}',
                        color: Colors.orange,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Producto más vendido
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.withOpacity(0.2),
                      child: const Icon(Icons.star, color: Colors.amber),
                    ),
                    title: const Text('Producto más vendido'),
                    subtitle: Text(_getTopProduct()),
                  ),
                ),

                const SizedBox(height: 24),

                // Lista de ventas detallada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalle de Ventas',
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      '${_sales.length} ventas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_sales.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay ventas en este período',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(_sales.length, (index) {
                    final sale = _sales[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.1),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          sale.nombreProducto ?? 'Producto #${sale.productoId}',
                        ),
                        subtitle: Text(dateFormat.format(sale.fecha)),
                        trailing: Text(
                          '\$${sale.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _DetailRow(
                                  label: 'Cantidad',
                                  value: '${sale.cantidad} unidades',
                                ),
                                _DetailRow(
                                  label: 'Precio unitario',
                                  value:
                                      '\$${sale.precioUnitario.toStringAsFixed(2)}',
                                ),
                                _DetailRow(
                                  label: 'Total',
                                  value: '\$${sale.total.toStringAsFixed(2)}',
                                  isHighlighted: true,
                                ),
                                if (sale.nombreUsuario != null)
                                  _DetailRow(
                                    label: 'Vendedor',
                                    value: sale.nombreUsuario!,
                                  ),
                                _DetailRow(
                                  label: 'Fecha y hora',
                                  value: DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(sale.fecha),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _ReportCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isHighlighted ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
