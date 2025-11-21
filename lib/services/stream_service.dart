import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/product.dart';
import '../models/sale.dart';
import 'database_helper.dart';
import 'notification_service.dart';

/// Servicio de Streams para actualizaciones en tiempo real
class StreamService {
  static final StreamService instance = StreamService._internal();
  factory StreamService() => instance;
  StreamService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;

  // BehaviorSubject mantiene el último valor emitido
  final _productosController = BehaviorSubject<List<Product>>();
  final _ventasController = BehaviorSubject<List<Sale>>();
  final _lowStockController = BehaviorSubject<List<Product>>();

  // Streams públicos
  Stream<List<Product>> get productosStream => _productosController.stream;
  Stream<List<Sale>> get ventasStream => _ventasController.stream;
  Stream<List<Product>> get lowStockStream => _lowStockController.stream;

  // Valores actuales
  List<Product> get currentProductos => _productosController.valueOrNull ?? [];
  List<Sale> get currentVentas => _ventasController.valueOrNull ?? [];
  List<Product> get currentLowStock => _lowStockController.valueOrNull ?? [];

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _notificationService.initialize();
    await refreshAll();

    _initialized = true;
    print('StreamService initialized');
  }

  // Refrescar todos los datos
  Future<void> refreshAll() async {
    await Future.wait([refreshProductos(), refreshVentas(), refreshLowStock()]);
  }

  // Refrescar productos
  Future<void> refreshProductos() async {
    try {
      final productos = await _dbHelper.getAllProductos();
      _productosController.add(productos);
    } catch (e) {
      _productosController.addError(e);
      print('Error refreshing productos: $e');
    }
  }

  // Refrescar ventas
  Future<void> refreshVentas() async {
    try {
      final ventas = await _dbHelper.getAllVentas();
      _ventasController.add(ventas);
    } catch (e) {
      _ventasController.addError(e);
      print('Error refreshing ventas: $e');
    }
  }

  // Refrescar productos con stock bajo
  Future<void> refreshLowStock() async {
    try {
      final lowStock = await _dbHelper.getProductosLowStock(10);
      _lowStockController.add(lowStock);

      // Notificar productos críticos (< 5 unidades)
      for (final producto in lowStock) {
        if (producto.cantidad < 5) {
          await _notificationService.showCriticalStockNotification(
            productName: producto.nombre,
            currentStock: producto.cantidad,
          );
        }
      }
    } catch (e) {
      _lowStockController.addError(e);
      print('Error refreshing low stock: $e');
    }
  }

  // Agregar producto
  Future<int> addProducto(Product producto) async {
    try {
      final id = await _dbHelper.insertProducto(producto);
      await refreshProductos();
      await refreshLowStock();
      return id;
    } catch (e) {
      print('Error adding producto: $e');
      rethrow;
    }
  }

  // Actualizar producto
  Future<void> updateProducto(Product producto) async {
    try {
      // Obtener stock anterior para comparar
      final oldProduct = await _dbHelper.getProductoById(producto.id!);

      await _dbHelper.updateProducto(producto);
      await refreshProductos();
      await refreshLowStock();

      // Verificar si cruzó umbral de stock bajo
      if (oldProduct != null) {
        await _notificationService.checkProductStock(
          productName: producto.nombre,
          currentStock: producto.cantidad,
          previousStock: oldProduct.cantidad,
        );
      }
    } catch (e) {
      print('Error updating producto: $e');
      rethrow;
    }
  }

  // Eliminar producto
  Future<void> deleteProducto(int id) async {
    try {
      await _dbHelper.deleteProducto(id);
      await refreshProductos();
      await refreshLowStock();
    } catch (e) {
      print('Error deleting producto: $e');
      rethrow;
    }
  }

  // Registrar venta
  Future<int> addVenta(Sale venta) async {
    try {
      final id = await _dbHelper.insertVenta(venta);

      // Actualizar ambos streams
      await Future.wait([
        refreshVentas(),
        refreshProductos(),
        refreshLowStock(),
      ]);

      return id;
    } catch (e) {
      print('Error adding venta: $e');
      rethrow;
    }
  }

  // Buscar productos (retorna Future, no Stream)
  Future<List<Product>> searchProductos(String query) async {
    return await _dbHelper.searchProductos(query);
  }

  // Obtener ventas por rango de fechas
  Future<List<Sale>> getVentasByDateRange(DateTime start, DateTime end) async {
    return await _dbHelper.getVentasByDateRange(start, end);
  }

  // Obtener ventas por usuario
  Future<List<Sale>> getVentasByUsuario(int usuarioId) async {
    return await _dbHelper.getVentasByUsuario(usuarioId);
  }

  // Stream combinado: productos con ventas
  Stream<Map<String, dynamic>> get dashboardStream {
    return Rx.combineLatest3(productosStream, ventasStream, lowStockStream, (
      productos,
      ventas,
      lowStock,
    ) {
      // Calcular estadísticas
      final today = DateTime.now();
      final ventasHoy = ventas.where((v) {
        return v.fecha.year == today.year &&
            v.fecha.month == today.month &&
            v.fecha.day == today.day;
      }).toList();

      final ingresosHoy = ventasHoy.fold<double>(
        0.0,
        (sum, venta) => sum + venta.total,
      );

      return {
        'productos': productos,
        'ventas': ventas,
        'lowStock': lowStock,
        'ventasHoy': ventasHoy.length,
        'ingresosHoy': ingresosHoy,
        'totalProductos': productos.length,
        'productosStockBajo': lowStock.length,
      };
    });
  }

  // Cerrar streams
  void dispose() {
    _productosController.close();
    _ventasController.close();
    _lowStockController.close();
  }
}
