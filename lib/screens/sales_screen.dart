import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';

/// Pantalla de registro de ventas
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  List<Product> _products = [];
  List<Sale> _recentSales = [];
  Product? _selectedProduct;
  final TextEditingController _cantidadController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  /// Carga productos y ventas recientes
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final products = await _dbHelper.getAllProductos();
      final sales = await _dbHelper.getAllVentas();

      setState(() {
        _products = products;
        _recentSales = sales.take(10).toList(); // Solo las últimas 10
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  /// Registra una nueva venta
  Future<void> _submitSale() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      return;
    }

    // Verificar que el usuario esté autenticado
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para registrar ventas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cantidad = int.parse(_cantidadController.text);

    // Verificar stock disponible
    if (cantidad > _selectedProduct!.cantidad) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente. Disponible: ${_selectedProduct!.cantidad}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Crear la venta
      final sale = Sale.create(
        productoId: _selectedProduct!.id!,
        usuarioId: _authService.currentUser!.id,
        cantidad: cantidad,
        precioUnitario: _selectedProduct!.precioUnitario,
      );

      // Insertar la venta
      await _dbHelper.insertVenta(sale);

      // Actualizar el stock del producto
      final updatedProduct = _selectedProduct!.copyWith(
        cantidad: _selectedProduct!.cantidad - cantidad,
        fechaActualizacion: DateTime.now(),
      );
      await _dbHelper.updateProducto(updatedProduct);

      // Limpiar formulario
      setState(() {
        _selectedProduct = null;
        _cantidadController.clear();
      });
      _formKey.currentState!.reset();

      // Recargar datos
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Venta registrada: \$${sale.total.toStringAsFixed(2)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar venta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Nueva Venta',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Formulario de venta
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seleccionar producto
                        DropdownButtonFormField<Product>(
                          value: _selectedProduct,
                          decoration: const InputDecoration(
                            labelText: 'Seleccionar Producto *',
                            prefixIcon: Icon(Icons.inventory_2),
                          ),
                          hint: const Text('Elige un producto'),
                          items: _products.map((product) {
                            return DropdownMenuItem<Product>(
                              value: product,
                              child: Text(
                                '${product.nombre} (Stock: ${product.cantidad})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Selecciona un producto';
                            }
                            return null;
                          },
                          onChanged: (product) {
                            setState(() {
                              _selectedProduct = product;
                            });
                          },
                        ),

                        // Mostrar información del producto seleccionado
                        if (_selectedProduct != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.05,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.2,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Precio unitario:',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '\$${_selectedProduct!.precioUnitario.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Disponible:',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${_selectedProduct!.cantidad} unidades',
                                      style: TextStyle(
                                        color: _selectedProduct!.isLowStock
                                            ? Colors.orange
                                            : Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Cantidad
                        TextFormField(
                          controller: _cantidadController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Cantidad *',
                            prefixIcon: Icon(Icons.numbers),
                            hintText: '0',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La cantidad es requerida';
                            }
                            final cantidad = int.tryParse(value);
                            if (cantidad == null || cantidad <= 0) {
                              return 'Cantidad inválida';
                            }
                            if (_selectedProduct != null &&
                                cantidad > _selectedProduct!.cantidad) {
                              return 'Stock insuficiente';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {}); // Para actualizar el total
                          },
                        ),

                        // Mostrar total calculado
                        if (_selectedProduct != null &&
                            _cantidadController.text.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${(_selectedProduct!.precioUnitario * (int.tryParse(_cantidadController.text) ?? 0)).toStringAsFixed(2)}',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Botón de registro
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: _isSubmitting ? null : _submitSale,
                            icon: _isSubmitting
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
                                : const Icon(Icons.check),
                            label: Text(
                              _isSubmitting
                                  ? 'Registrando...'
                                  : 'Registrar Venta',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Últimas ventas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Últimas Ventas', style: theme.textTheme.headlineSmall),
                  if (_recentSales.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        // Navegar a la pantalla de reportes
                        DefaultTabController.of(context).animateTo(3);
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Ver todas'),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de ventas recientes
              if (_recentSales.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay ventas registradas',
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
                ...List.generate(_recentSales.length, (index) {
                  final sale = _recentSales[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        sale.nombreProducto ?? 'Producto #${sale.productoId}',
                      ),
                      subtitle: Text(
                        '${sale.cantidad} unidades - ${dateFormat.format(sale.fecha)}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${sale.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (sale.nombreUsuario != null)
                            Text(
                              sale.nombreUsuario!,
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
