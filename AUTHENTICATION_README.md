# Sistema de Gestión de Ventas - Distribuidora Oficina

## 📱 Autenticación y Persistencia de Sesión

### ✅ Funcionalidades Implementadas

#### 1. **Sistema de Autenticación Completo**

- ✅ Login con validaciones
- ✅ Registro de nuevos usuarios
- ✅ Persistencia de sesión con SharedPreferences
- ✅ Cierre de sesión
- ✅ Auto-login al iniciar la app si hay sesión activa

#### 2. **Gestión de Perfil de Usuario**

- ✅ Visualización de perfil
- ✅ Edición de perfil (nombre, email, teléfono)
- ✅ Actualización en tiempo real
- ✅ Validaciones de formularios

#### 3. **Validación de Permisos**

- ✅ Verificación de permisos de almacenamiento
- ✅ Verificación de acceso a internet
- ✅ Solicitud de permisos de notificaciones
- ✅ Solicitud de permisos de ubicación

---

## 🔐 Credenciales de Prueba

### Usuario Demo (Siempre disponible)

```
Email: demo@empresa.com
Contraseña: 123456
```

### Crear nuevo usuario

Puedes registrar un nuevo usuario desde la pantalla de registro. Los datos se guardan localmente en SharedPreferences.

---

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada con SplashScreen
├── models/
│   └── user.dart               # Modelo de Usuario
├── services/
│   ├── auth_service.dart       # Servicio de autenticación
│   └── permissions_service.dart # Servicio de permisos
├── screens/
│   ├── login_screen.dart       # Pantalla de login
│   ├── register_screen.dart    # Pantalla de registro
│   ├── edit_profile_screen.dart # Edición de perfil
│   ├── profile_screen.dart     # Visualización de perfil
│   ├── main_screen.dart        # Navegación principal
│   ├── home_screen.dart        # Dashboard
│   ├── inventory_screen.dart   # Gestión de inventario
│   ├── sales_screen.dart       # Registro de ventas
│   ├── reports_screen.dart     # Reportes
│   └── map_screen.dart         # Mapa
├── utils/
│   └── theme.dart             # Tema corporativo
└── widgets/                    # Widgets reutilizables
```

---

## 🛠️ Tecnologías y Dependencias

### Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2 # Persistencia local
  permission_handler: ^11.3.0 # Gestión de permisos
  intl: ^0.19.0 # Formateo de fechas
```

---

## 🎯 Características de Autenticación

### 1. **Persistencia de Sesión**

La aplicación verifica automáticamente si hay una sesión activa al iniciar:

```dart
// En SplashScreen (main.dart)
final isLoggedIn = await _authService.isLoggedIn();

if (isLoggedIn) {
  // Redirigir a MainScreen
} else {
  // Redirigir a LoginScreen
}
```

### 2. **Almacenamiento Seguro**

Los datos del usuario se guardan en SharedPreferences:

- `is_logged_in`: Estado de sesión (bool)
- `current_user`: Datos del usuario actual (JSON)
- `users_database`: Base de datos local de usuarios (JSON)

### 3. **Validaciones**

- Email válido con formato correcto
- Contraseña mínimo 6 caracteres
- Confirmación de contraseña coincidente
- Nombre mínimo 3 caracteres
- Email único en registro

---

## 🚀 Flujo de Autenticación

### Login

1. Usuario ingresa email y contraseña
2. AuthService valida credenciales
3. Si son correctas, guarda sesión en SharedPreferences
4. Navega a MainScreen

### Registro

1. Usuario completa formulario
2. Sistema valida que email no exista
3. Crea nuevo usuario
4. Auto-login automático
5. Navega a MainScreen

### Persistencia

1. Al abrir la app, SplashScreen verifica sesión
2. Si `is_logged_in == true`, carga usuario y va a MainScreen
3. Si no hay sesión, va a LoginScreen

### Cierre de Sesión

1. Usuario confirma en diálogo
2. AuthService limpia SharedPreferences
3. Navega de vuelta a LoginScreen

---

## 📱 Permisos

### Solicitados al Iniciar

- ✅ Almacenamiento local (SharedPreferences)

### Disponibles para Solicitar

- Notificaciones (para alertas de inventario)
- Ubicación (para funcionalidad de mapas)
- Internet (disponible por defecto en la mayoría de plataformas)

---

## 🔄 Actualización de Perfil

El usuario puede editar su perfil desde:

1. Pantalla de Perfil → "Editar Perfil"
2. Modificar: Nombre, Email, Teléfono
3. Los cambios se guardan en SharedPreferences
4. Se actualizan en la base de datos local

---

## 📝 Notas Técnicas

### Patrón Singleton

Los servicios utilizan el patrón Singleton para mantener una única instancia:

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
}
```

### Manejo de Estados

- Login/Registro: Estados locales con StatefulWidget
- Perfil: Recarga de datos al regresar de edición
- Sesión: Verificación en SplashScreen

### Seguridad

⚠️ **Nota**: Esta es una implementación de demostración. En producción:

- Las contraseñas deben estar hasheadas (bcrypt, argon2, etc.)
- Usar autenticación con servidor/API
- Implementar tokens JWT o similar
- Usar almacenamiento seguro (flutter_secure_storage)

---

## 🎨 Tema Corporativo

Paleta de colores:

- **Azul Corporativo**: `#1565C0` (Primary)
- **Azul Claro**: `#42A5F5` (Secondary)
- **Gris Corporativo**: `#607D8B`
- **Colores de Estado**:
  - Verde: `#4CAF50` (Éxito)
  - Naranja: `#FF9800` (Advertencia)
  - Rojo: `#E53935` (Error)

---

## ✨ Próximas Mejoras

- [ ] Cambio de contraseña funcional
- [ ] Recuperación de contraseña por email
- [ ] Foto de perfil
- [ ] Autenticación biométrica (huella/FaceID)
- [ ] Sincronización con servidor
- [ ] Multi-idioma

---

## 📞 Soporte

Para más información sobre el proyecto, consulta la documentación de Flutter:

- [Flutter Documentation](https://flutter.dev/docs)
- [SharedPreferences Package](https://pub.dev/packages/shared_preferences)
- [Permission Handler Package](https://pub.dev/packages/permission_handler)

---

**Desarrollado con ❤️ usando Flutter**
