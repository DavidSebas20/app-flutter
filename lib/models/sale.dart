/// Modelo de Venta
class Sale {
  final int? id;
  final int productoId;
  final String usuarioId;
  final DateTime fecha;
  final int cantidad;
  final double precioUnitario;
  final double total;

  // Campos adicionales para joins
  String? nombreProducto;
  String? nombreUsuario;

  Sale({
    this.id,
    required this.productoId,
    required this.usuarioId,
    DateTime? fecha,
    required this.cantidad,
    required this.precioUnitario,
    required this.total,
    this.nombreProducto,
    this.nombreUsuario,
  }) : fecha = fecha ?? DateTime.now();

  /// Convierte la venta a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'usuario_id': usuarioId,
      'fecha': fecha.toIso8601String(),
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'total': total,
    };
  }

  /// Crea una venta desde un Map de SQLite
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      productoId: map['producto_id'] as int,
      usuarioId: map['usuario_id'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      cantidad: map['cantidad'] as int,
      precioUnitario: map['precio_unitario'] as double,
      total: map['total'] as double,
      nombreProducto: map['nombre_producto'] as String?,
      nombreUsuario: map['nombre_usuario'] as String?,
    );
  }

  /// Factory para crear venta con cálculo automático del total
  factory Sale.create({
    required int productoId,
    required String usuarioId,
    required int cantidad,
    required double precioUnitario,
    DateTime? fecha,
  }) {
    final total = cantidad * precioUnitario;
    return Sale(
      productoId: productoId,
      usuarioId: usuarioId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      total: total,
      fecha: fecha,
    );
  }

  /// Copia la venta con nuevos valores opcionales
  Sale copyWith({
    int? id,
    int? productoId,
    String? usuarioId,
    DateTime? fecha,
    int? cantidad,
    double? precioUnitario,
    double? total,
    String? nombreProducto,
    String? nombreUsuario,
  }) {
    return Sale(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      usuarioId: usuarioId ?? this.usuarioId,
      fecha: fecha ?? this.fecha,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      total: total ?? this.total,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
    );
  }

  @override
  String toString() {
    return 'Sale(id: $id, producto: $nombreProducto, cantidad: $cantidad, total: \$$total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sale &&
        other.id == id &&
        other.productoId == productoId &&
        other.usuarioId == usuarioId;
  }

  @override
  int get hashCode => id.hashCode ^ productoId.hashCode ^ usuarioId.hashCode;
}
