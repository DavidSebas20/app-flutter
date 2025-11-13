import 'dart:convert';

/// Modelo de usuario del sistema
/// Contiene toda la información del usuario autenticado
class User {
  final String id;
  String nombre;
  String email;
  String telefono;
  String? password; // Solo se usa para registro/login, no se persiste

  User({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono = '',
    this.password,
  });

  /// Crea un usuario desde un Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String? ?? '',
      password: json['password'] as String?,
    );
  }

  /// Convierte el usuario a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      // No incluimos password en la serialización por seguridad
    };
  }

  /// Convierte el usuario a String JSON
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Crea un usuario desde un String JSON
  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Copia el usuario con nuevos valores opcionales
  User copyWith({
    String? id,
    String? nombre,
    String? email,
    String? telefono,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, nombre: $nombre, email: $email, telefono: $telefono)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.nombre == nombre &&
        other.email == email &&
        other.telefono == telefono;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nombre.hashCode ^ email.hashCode ^ telefono.hashCode;
  }
}
