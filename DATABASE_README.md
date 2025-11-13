# Sistema de Inventario y Ventas con SQLite

## 📋 Descripción General

Sistema completo de gestión de inventario y ventas para una empresa de distribución de productos de oficina, desarrollado en Flutter con integración de base de datos SQLite.

## 🗃️ Base de Datos SQLite

### Estructura de Tablas

#### Tabla `usuarios`

```sql
CREATE TABLE usuarios (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  telefono TEXT,
  fecha_creacion TEXT NOT NULL,
  fecha_actualizacion TEXT NOT NULL
)
```

#### Tabla `productos`

```sql
CREATE TABLE productos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  cantidad INTEGER NOT NULL DEFAULT 0,
  precio_unitario REAL NOT NULL,
  categoria TEXT,
  descripcion TEXT,
  fecha_creacion TEXT NOT NULL,
  fecha_actualizacion TEXT NOT NULL
)
```

#### Tabla `ventas`

```sql
CREATE TABLE ventas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  producto_id INTEGER NOT NULL,
  usuario_id TEXT NOT NULL,
  fecha TEXT NOT NULL,
  cantidad INTEGER NOT NULL,
  precio_unitario REAL NOT NULL,
  total REAL NOT NULL,
  FOREIGN KEY (producto_id) REFERENCES productos (id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
)
```

### Índices para Optimización

- `idx_ventas_usuario`: Índice en `ventas.usuario_id`
- `idx_ventas_fecha`: Índice en `ventas.fecha`
- `idx_ventas_producto`: Índice en `ventas.producto_id`

## ✨ Funcionalidades Implementadas

### 1. Gestión de Inventario 📦

#### Pantalla: `InventoryScreen`

- **Visualización de productos**: Lista completa de productos desde SQLite
- **Búsqueda**: Filtrado por nombre o descripción en tiempo real
- **Filtros por categoría**: Chips de categorías dinámicos
- **Estadísticas en tiempo real**:
  - Total de productos
  - Productos con stock bajo (≤5 unidades)
- **CRUD completo**:
  - ✅ Crear productos con formulario validado
  - ✅ Editar productos existentes
  - ✅ Eliminar productos con confirmación
  - ✅ Visualizar detalles completos
- **Alertas de stock bajo**: Indicadores visuales para productos críticos
- **Pull-to-refresh**: Actualizar lista deslizando hacia abajo

#### Widget: `ProductFormDialog`

- Formulario modal con validaciones completas
- Campos:
  - Nombre (requerido, mínimo 3 caracteres)
  - Cantidad (requerido, solo números positivos)
  - Precio unitario (requerido, formato decimal)
  - Categoría (opcional)
  - Descripción (opcional, multilínea)
- Cálculo automático de valor total en inventario
- Modo agregar y modo editar
- Timestamps automáticos

### 2. Registro de Ventas 💰

#### Pantalla: `SalesScreen`

- **Formulario de venta**:
  - Dropdown de productos con stock disponible
  - Visualización de precio unitario y stock
  - Campo de cantidad con validación de stock
  - Cálculo automático de total
  - Validación de usuario autenticado
- **Transacciones atómicas**:
  - Registro de venta en tabla `ventas`
  - Actualización automática de stock en tabla `productos`
  - Rollback en caso de error
- **Historial de ventas**:
  - Últimas 10 ventas registradas
  - Información de producto y vendedor
  - Timestamp formateado
  - Total de cada transacción
- **Validaciones**:
  - Solo usuarios autenticados pueden vender
  - Verificación de stock disponible
  - Cantidades positivas obligatorias
- **Pull-to-refresh**: Actualizar ventas

### 3. Reportes y Estadísticas 📊

#### Pantalla: `ReportsScreen`

- **Filtros avanzados**:
  - Rango de fechas con DatePicker
  - Filtro "Solo mis ventas" (por usuario)
  - Botón "Aplicar filtros" para ejecutar query
- **Estadísticas calculadas**:
  - Total de ventas en dinero
  - Número de transacciones
  - Promedio de venta
  - Total de productos vendidos
  - Producto más vendido del período
- **Listado detallado**:
  - Todas las ventas del período filtrado
  - Tiles expandibles con información completa
  - Información del vendedor
  - Fecha y hora exacta
  - Desglose de cantidad y precios
- **Pull-to-refresh**: Actualizar reportes
- **Queries optimizadas**: Uso de JOINs para datos relacionales

### 4. Sincronización de Usuarios 👥

#### Servicio: `AuthService` (actualizado)

- **Migración automática**: Usuarios de SharedPreferences a SQLite en login
- **Registro dual**: Guarda en SQLite y SharedPreferences
- **Usuario demo**: Incluido automáticamente en SQLite
  - Email: `demo@empresa.com`
  - Password: `123456`
- **Actualización de perfil**: Sincroniza en ambos sistemas
- **Validaciones**:
  - Email único en SQLite
  - Contraseñas almacenadas (producción requiere hash)

## 🛠️ Servicios y Arquitectura

### `DatabaseHelper` (Singleton)

- **Ubicación**: `lib/services/database_helper.dart`
- **Funciones principales**:
  - Gestión de conexión SQLite
  - Creación de tablas con `onCreate`
  - Migraciones con `onUpgrade`
  - CRUD para usuarios, productos y ventas
  - Queries con JOINs para reportes
  - Estadísticas agregadas
  - Datos de prueba inicial

### Modelos de Datos

#### `Product`

```dart
class Product {
  final int? id;
  String nombre;
  int cantidad;
  double precioUnitario;
  String? categoria;
  String? descripcion;
  DateTime? fechaCreacion;
  DateTime? fechaActualizacion;

  // Getters calculados
  bool get isLowStock => cantidad <= 5;
  double get valorTotal => cantidad * precioUnitario;

  // Serialización SQLite
  Map<String, dynamic> toMap();
  factory Product.fromMap(Map<String, dynamic> map);
  Product copyWith(...);
}
```

#### `Sale`

```dart
class Sale {
  final int? id;
  final int productoId;
  final String usuarioId;
  final DateTime fecha;
  final int cantidad;
  final double precioUnitario;
  final double total;

  // Campos para JOINs
  String? nombreProducto;
  String? nombreUsuario;

  // Factory con cálculo automático
  factory Sale.create({...});

  // Serialización SQLite
  Map<String, dynamic> toMap();
  factory Sale.fromMap(Map<String, dynamic> map);
}
```

## 📱 Flujo de Usuario

### Inventario

1. Ver lista de productos con estadísticas
2. Buscar productos por nombre/descripción
3. Filtrar por categoría usando chips
4. Click en producto para editar
5. Menu contextual para eliminar
6. FAB "Nuevo Producto" para agregar
7. Identificar visualmente productos con stock bajo

### Ventas

1. Seleccionar producto del dropdown
2. Sistema muestra precio y stock disponible
3. Ingresar cantidad deseada
4. Ver cálculo automático del total
5. Presionar "Registrar Venta"
6. Validación de usuario y stock
7. Actualización automática de inventario
8. Confirmación visual con SnackBar
9. Venta aparece en historial

### Reportes

1. Seleccionar rango de fechas
2. Activar/desactivar filtro "Solo mis ventas"
3. Presionar "Aplicar Filtros"
4. Ver estadísticas del período
5. Expandir ventas para ver detalles
6. Navegar a "Ver todas" para más opciones

## 🔒 Seguridad y Validaciones

- ✅ Autenticación requerida para ventas
- ✅ Validación de stock en cada venta
- ✅ Emails únicos en registro
- ✅ Validación de tipos de datos en formularios
- ✅ Confirmación para acciones destructivas
- ✅ Manejo de errores con try-catch
- ✅ Foreign keys con ON DELETE CASCADE

## 🎨 UX/UI Highlights

- **Material Design 3** con tema corporativo
- **Pull-to-refresh** en todas las pantallas de datos
- **Diálogos modales** para formularios
- **Indicadores de carga** durante operaciones async
- **SnackBars** para feedback inmediato
- **Chips de filtro** para categorías
- **Expansion Tiles** para detalles de ventas
- **Badges visuales** para stock bajo
- **Iconografía consistente** en toda la app

## 📊 Datos de Prueba Incluidos

Al crear la base de datos, se insertan automáticamente 5 productos:

1. **Papel Bond Tamaño Carta** - 150 unidades - $89.99
2. **Bolígrafos Azules Caja 12** - 4 unidades - $45.50 ⚠️ Stock bajo
3. **Carpetas Tamaño Carta** - 80 unidades - $25.00
4. **Marcadores Permanentes** - 3 unidades - $35.00 ⚠️ Stock bajo
5. **Grapadora Metálica** - 25 unidades - $125.00

## 🚀 Mejoras Futuras Sugeridas

1. **Seguridad**:

   - Implementar hash de contraseñas (bcrypt)
   - Tokens JWT para sesiones
   - Permisos basados en roles

2. **Funcionalidades**:

   - Exportar reportes a PDF/Excel
   - Gráficos de ventas con charts_flutter
   - Notificaciones push para stock bajo
   - Historial de cambios en productos
   - Búsqueda de ventas por producto/usuario

3. **Base de Datos**:

   - Backup automático de BD
   - Sincronización con servidor remoto
   - Modo offline con cola de sincronización

4. **UX**:
   - Modo oscuro
   - Escaneo de código de barras
   - Búsqueda por voz
   - Animaciones de transición

## 🧪 Cómo Probar

1. Iniciar sesión con usuario demo:

   - Email: `demo@empresa.com`
   - Password: `123456`

2. **Probar Inventario**:

   - Navegar a pestaña "Inventario"
   - Buscar "papel" en el campo de búsqueda
   - Filtrar por categoría "Escritura"
   - Crear un producto nuevo
   - Editar un producto existente
   - Eliminar un producto (con confirmación)
   - Observar alerta de stock bajo en productos

3. **Probar Ventas**:

   - Navegar a pestaña "Ventas"
   - Seleccionar "Papel Bond Tamaño Carta"
   - Ingresar cantidad 10
   - Verificar cálculo automático
   - Registrar venta
   - Observar actualización en historial
   - Verificar stock actualizado en inventario

4. **Probar Reportes**:
   - Navegar a pestaña "Reportes"
   - Ver estadísticas del mes actual
   - Cambiar rango de fechas
   - Activar "Solo mis ventas"
   - Aplicar filtros
   - Expandir venta para ver detalles
   - Verificar producto más vendido

## 📦 Dependencias Utilizadas

```yaml
dependencies:
  sqflite: ^2.3.0 # Base de datos SQLite
  path: ^1.8.3 # Rutas de archivos
  shared_preferences: ^2.2.2 # Persistencia de sesión
  intl: ^0.19.0 # Formateo de fechas
```

## 📝 Estructura de Archivos

```
lib/
├── models/
│   ├── user.dart
│   ├── product.dart
│   └── sale.dart
├── services/
│   ├── database_helper.dart
│   └── auth_service.dart
├── screens/
│   ├── inventory_screen.dart
│   ├── sales_screen.dart
│   └── reports_screen.dart
├── widgets/
│   └── product_form_dialog.dart
└── main.dart
```

## ✅ Checklist de Funcionalidades

### Inventario y Productos

- [x] Base de datos SQLite con tabla productos
- [x] CRUD completo de productos
- [x] Búsqueda por nombre/descripción
- [x] Filtros por categoría
- [x] Alerta de stock bajo (≤5 unidades)
- [x] Formulario de producto con validaciones
- [x] Cálculo de valor total de inventario
- [x] Timestamps de creación y actualización

### Ventas

- [x] Base de datos SQLite con tabla ventas
- [x] Registro de ventas vinculadas a usuarios
- [x] Validación de usuario autenticado
- [x] Verificación de stock disponible
- [x] Actualización automática de inventario
- [x] Cálculo automático de totales
- [x] Historial de ventas recientes
- [x] Foreign keys para integridad referencial

### Reportes

- [x] Filtros por rango de fechas
- [x] Filtro por usuario (mis ventas)
- [x] Estadísticas: total ventas, transacciones, promedio
- [x] Producto más vendido
- [x] Listado detallado con expand
- [x] Queries con JOIN para datos relacionales

### Sistema

- [x] Sincronización usuarios SQLite/SharedPreferences
- [x] Migración automática de usuarios antiguos
- [x] Manejo de errores con try-catch
- [x] Pull-to-refresh en todas las pantallas
- [x] Indicadores de carga
- [x] Feedback visual con SnackBars

---

**Versión**: 1.0.0  
**Fecha**: $(Get-Date -Format "dd/MM/yyyy")  
**Desarrollado con**: Flutter SDK 3.10.0 + SQLite
