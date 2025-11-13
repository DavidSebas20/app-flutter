/// Modelo de Producto para el inventario
class Product {
  final int? id;
  String nombre;
  int cantidad;
  double precioUnitario;
  String? categoria;
  String? descripcion;
  DateTime? fechaCreacion;
  DateTime? fechaActualizacion;

  Product({
    this.id,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    this.categoria,
    this.descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now(),
       fechaActualizacion = fechaActualizacion ?? DateTime.now();

  /// Convierte el producto a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'categoria': categoria,
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  /// Crea un producto desde un Map de SQLite
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      cantidad: map['cantidad'] as int,
      precioUnitario: map['precio_unitario'] as double,
      categoria: map['categoria'] as String?,
      descripcion: map['descripcion'] as String?,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'] as String)
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.parse(map['fecha_actualizacion'] as String)
          : null,
    );
  }

  /// Copia el producto con nuevos valores opcionales
  Product copyWith({
    int? id,
    String? nombre,
    int? cantidad,
    double? precioUnitario,
    String? categoria,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  /// Verifica si el producto tiene stock bajo (≤5 unidades)
  bool get isLowStock => cantidad <= 5;

  /// Calcula el valor total del inventario de este producto
  double get valorTotal => cantidad * precioUnitario;

  @override
  String toString() {
    return 'Product(id: $id, nombre: $nombre, cantidad: $cantidad, precio: $precioUnitario)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.id == id && other.nombre == nombre;
  }

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode;
}
