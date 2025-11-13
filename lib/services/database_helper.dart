import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/sale.dart';

/// DatabaseHelper con soporte multiplataforma
/// Usa SQLite para Android/iOS/Desktop y SharedPreferences para Web
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static SharedPreferences? _prefs;
  
  // Usar SQLite solo en plataformas nativas
  static final bool _useSqlite = !kIsWeb;

  DatabaseHelper._init();

  // Nombres de tablas (solo para SQLite)
  static const String tableProductos = 'productos';
  static const String tableVentas = 'ventas';

  // Keys para SharedPreferences (solo para Web)
  static const String _keyProductos = 'productos_database';
  static const String _keyVentas = 'ventas_database';
  static const String _keyNextProductId = 'next_product_id';
  static const String _keyNextVentaId = 'next_venta_id';

  Future<Database?> get database async {
    if (!_useSqlite) return null;
    
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<SharedPreferences> get _preferences async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    if (!_useSqlite) await _initializeDataWeb();
    return _prefs!;
  }

  Future<Database> _initDatabase() async {
    // Inicializar FFI para desktop
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de productos
    await db.execute('''
      CREATE TABLE $tableProductos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio_unitario REAL NOT NULL,
        cantidad INTEGER NOT NULL,
        categoria TEXT,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT
      )
    ''');

    // Tabla de ventas
    await db.execute('''
      CREATE TABLE $tableVentas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto_id INTEGER NOT NULL,
        usuario_id TEXT NOT NULL,
        fecha TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (producto_id) REFERENCES $tableProductos (id) ON DELETE CASCADE
      )
    ''');

    // Insertar datos de ejemplo
    await _insertSampleData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Manejar actualizaciones futuras
  }

  Future<void> _insertSampleData(Database db) async {
    final productos = [
      {
        'nombre': 'Papel Bond A4',
        'descripcion': 'Resma de 500 hojas',
        'precio_unitario': 25.50,
        'cantidad': 100,
        'categoria': 'Papelería',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
      {
        'nombre': 'Bolígrafo Azul',
        'descripcion': 'Caja con 12 unidades',
        'precio_unitario': 8.00,
        'cantidad': 50,
        'categoria': 'Escritura',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
      {
        'nombre': 'Carpeta Manila',
        'descripcion': 'Tamaño oficio',
        'precio_unitario': 1.50,
        'cantidad': 200,
        'categoria': 'Archivo',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
      {
        'nombre': 'Grapadora',
        'descripcion': 'Capacidad 20 hojas',
        'precio_unitario': 15.00,
        'cantidad': 30,
        'categoria': 'Oficina',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
      {
        'nombre': 'Marcador Permanente',
        'descripcion': 'Negro, punta fina',
        'precio_unitario': 3.50,
        'cantidad': 75,
        'categoria': 'Escritura',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
    ];

    for (var producto in productos) {
      await db.insert(tableProductos, producto);
    }
  }

  // ==================== MÉTODOS PARA WEB (SharedPreferences) ====================

  Future<void> _initializeDataWeb() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyProductos)) {
      final sampleProducts = [
        Product(
          id: 1,
          nombre: 'Papel Bond A4',
          descripcion: 'Resma de 500 hojas',
          precioUnitario: 25.50,
          cantidad: 100,
          categoria: 'Papelería',
        ),
        Product(
          id: 2,
          nombre: 'Bolígrafo Azul',
          descripcion: 'Caja con 12 unidades',
          precioUnitario: 8.00,
          cantidad: 50,
          categoria: 'Escritura',
        ),
        Product(
          id: 3,
          nombre: 'Carpeta Manila',
          descripcion: 'Tamaño oficio',
          precioUnitario: 1.50,
          cantidad: 200,
          categoria: 'Archivo',
        ),
        Product(
          id: 4,
          nombre: 'Grapadora',
          descripcion: 'Capacidad 20 hojas',
          precioUnitario: 15.00,
          cantidad: 30,
          categoria: 'Oficina',
        ),
        Product(
          id: 5,
          nombre: 'Marcador Permanente',
          descripcion: 'Negro, punta fina',
          precioUnitario: 3.50,
          cantidad: 75,
          categoria: 'Escritura',
        ),
      ];

      await prefs.setStringList(
        _keyProductos,
        sampleProducts.map((p) => jsonEncode(p.toMap())).toList(),
      );
      await prefs.setInt(_keyNextProductId, 6);
    }

    if (!prefs.containsKey(_keyVentas)) {
      await prefs.setStringList(_keyVentas, []);
      await prefs.setInt(_keyNextVentaId, 1);
    }
  }

  // ==================== MÉTODOS DE PRODUCTOS ====================

  Future<int> insertProducto(Product producto) async {
    if (_useSqlite) {
      final db = await database;
      return await db!.insert(tableProductos, producto.toMap());
    } else {
      final prefs = await _preferences;
      final nextId = prefs.getInt(_keyNextProductId) ?? 1;

      final productoConId = Product(
        id: nextId,
        nombre: producto.nombre,
        descripcion: producto.descripcion,
        precioUnitario: producto.precioUnitario,
        cantidad: producto.cantidad,
        categoria: producto.categoria,
      );

      final productos = await getAllProductos();
      productos.add(productoConId);

      await prefs.setStringList(
        _keyProductos,
        productos.map((p) => jsonEncode(p.toMap())).toList(),
      );
      await prefs.setInt(_keyNextProductId, nextId + 1);

      return nextId;
    }
  }

  Future<List<Product>> getAllProductos() async {
    if (_useSqlite) {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db!.query(tableProductos);
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    } else {
      final prefs = await _preferences;
      final productosJson = prefs.getStringList(_keyProductos) ?? [];
      return productosJson
          .map((json) => Product.fromMap(jsonDecode(json)))
          .toList();
    }
  }

  Future<Product?> getProductoById(int id) async {
    if (_useSqlite) {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db!.query(
        tableProductos,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return Product.fromMap(maps.first);
    } else {
      final productos = await getAllProductos();
      try {
        return productos.firstWhere((p) => p.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  Future<List<Product>> searchProductos(String query) async {
    final productos = await getAllProductos();
    final lowerQuery = query.toLowerCase();
    return productos.where((p) {
      return p.nombre.toLowerCase().contains(lowerQuery) ||
          (p.descripcion?.toLowerCase().contains(lowerQuery) ?? false) ||
          (p.categoria?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<List<Product>> getProductosLowStock(int threshold) async {
    if (_useSqlite) {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db!.query(
        tableProductos,
        where: 'cantidad < ?',
        whereArgs: [threshold],
      );
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    } else {
      final productos = await getAllProductos();
      return productos.where((p) => p.cantidad < threshold).toList();
    }
  }

  Future<int> updateProducto(Product producto) async {
    if (_useSqlite) {
      final db = await database;
      return await db!.update(
        tableProductos,
        producto.toMap(),
        where: 'id = ?',
        whereArgs: [producto.id],
      );
    } else {
      final prefs = await _preferences;
      final productos = await getAllProductos();

      final index = productos.indexWhere((p) => p.id == producto.id);
      if (index == -1) return 0;

      productos[index] = producto;

      await prefs.setStringList(
        _keyProductos,
        productos.map((p) => jsonEncode(p.toMap())).toList(),
      );

      return 1;
    }
  }

  Future<int> deleteProducto(int id) async {
    if (_useSqlite) {
      final db = await database;
      return await db!.delete(
        tableProductos,
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      final prefs = await _preferences;
      final productos = await getAllProductos();

      final lengthBefore = productos.length;
      productos.removeWhere((p) => p.id == id);

      if (productos.length == lengthBefore) return 0;

      await prefs.setStringList(
        _keyProductos,
        productos.map((p) => jsonEncode(p.toMap())).toList(),
      );

      return 1;
    }
  }

  // ==================== MÉTODOS DE VENTAS ====================

  Future<int> insertVenta(Sale venta) async {
    // Primero actualizar el stock del producto
    final producto = await getProductoById(venta.productoId);
    if (producto != null) {
      final nuevoStock = producto.cantidad - venta.cantidad;
      await updateProducto(Product(
        id: producto.id,
        nombre: producto.nombre,
        descripcion: producto.descripcion,
        precioUnitario: producto.precioUnitario,
        cantidad: nuevoStock,
        categoria: producto.categoria,
      ));
    }

    if (_useSqlite) {
      final db = await database;
      return await db!.insert(tableVentas, venta.toMap());
    } else {
      final prefs = await _preferences;
      final nextId = prefs.getInt(_keyNextVentaId) ?? 1;

      final ventaConId = Sale(
        id: nextId,
        productoId: venta.productoId,
        usuarioId: venta.usuarioId,
        cantidad: venta.cantidad,
        precioUnitario: venta.precioUnitario,
        total: venta.total,
        fecha: venta.fecha,
      );

      final ventas = await getAllVentas();
      ventas.add(ventaConId);

      await prefs.setStringList(
        _keyVentas,
        ventas.map((v) => jsonEncode(v.toMap())).toList(),
      );
      await prefs.setInt(_keyNextVentaId, nextId + 1);

      return nextId;
    }
  }

  Future<List<Sale>> getAllVentas() async {
    if (_useSqlite) {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db!.query(tableVentas);
      return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
    } else {
      final prefs = await _preferences;
      final ventasJson = prefs.getStringList(_keyVentas) ?? [];
      return ventasJson.map((json) => Sale.fromMap(jsonDecode(json))).toList();
    }
  }

  Future<List<Sale>> getVentasByUsuario(int usuarioId) async {
    final ventas = await getAllVentas();
    return ventas.where((v) => v.usuarioId == usuarioId.toString()).toList();
  }

  Future<List<Sale>> getVentasByDateRange(
      DateTime inicio, DateTime fin) async {
    final ventas = await getAllVentas();
    return ventas.where((v) {
      return v.fecha.isAfter(inicio.subtract(const Duration(days: 1))) &&
          v.fecha.isBefore(fin.add(const Duration(days: 1)));
    }).toList();
  }

  Future<Map<String, dynamic>> getVentasStats() async {
    final ventas = await getAllVentas();

    if (ventas.isEmpty) {
      return {
        'total_ventas': 0,
        'cantidad_ventas': 0,
        'promedio_venta': 0.0,
      };
    }

    final totalVentas = ventas.fold<double>(0, (sum, v) => sum + v.total);
    final cantidadVentas = ventas.length;
    final promedioVenta = totalVentas / cantidadVentas;

    return {
      'total_ventas': totalVentas,
      'cantidad_ventas': cantidadVentas,
      'promedio_venta': promedioVenta,
    };
  }

  Future<void> close() async {
    final db = await database;
    if (db != null) {
      await db.close();
    }
  }
}
