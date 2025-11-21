# Aplicación de Distribución de Productos de Oficina

## 🚀 Funcionalidades Avanzadas Implementadas

### 1. API REST - Cotización del Dólar

- **Servicio**: `CurrencyService`
- **Funcionalidad**: Consume API de tasas de cambio en tiempo real
- **API utilizada**: ExchangeRate-API (gratuita)
- **Características**:
  - Muestra cotización USD a COP (peso colombiano)
  - Cache de 1 hora para optimizar consultas
  - Botón de actualización manual
  - Manejo de errores de conexión
  - Visualización en tarjeta con diseño atractivo en Home

### 2. Notificaciones Locales

- **Servicio**: `NotificationService`
- **Funcionalidad**: Alertas push locales para stock crítico
- **Umbrales**:
  - **Stock Bajo**: < 10 unidades (alerta naranja)
  - **Stock Crítico**: < 5 unidades (alerta roja con vibración)
- **Características**:
  - Notificaciones automáticas al cruzar umbrales
  - Soporte para Android e iOS
  - No disponible en Web
  - Canales separados por prioridad
  - Vibración y sonido en alertas críticas

### 3. Google Maps Integration

- **Pantalla**: `MapsScreen`
- **Funcionalidad**: Visualización de ubicaciones estratégicas
- **Características**:
  - Ubicación de la oficina principal
  - Marcadores de clientes principales
  - Ubicación en tiempo real del usuario
  - Círculo de cobertura (5km de radio)
  - Lista interactiva de ubicaciones
  - Navegación animada al seleccionar ubicación
  - Botones de acceso rápido (Mi ubicación, Oficina)

**Nota**: Requiere API Key de Google Maps en `AndroidManifest.xml`

### 4. UI Responsive y Adaptativa

- **Widget**: `ResponsiveBuilder`
- **Breakpoints**:
  - **Mobile**: < 600px
  - **Tablet**: 600-900px
  - **Desktop**: > 900px
- **Componentes Responsive**:
  - `ResponsiveGrid`: Grid adaptativo
  - `ResponsivePadding`: Espaciado dinámico
  - `ResponsiveText`: Texto escalable
  - `ResponsiveContainer`: Ancho máximo en desktop
  - `ResponsiveValue`: Valores por dispositivo
- **Extensions**:
  - `context.isMobile`, `isTablet`, `isDesktop`
  - `context.screenWidth`, `screenHeight`

### 5. Streams y Actualizaciones en Tiempo Real

- **Servicio**: `StreamService` (con RxDart)
- **Streams disponibles**:
  - `productosStream`: Lista de productos actualizada
  - `ventasStream`: Ventas en tiempo real
  - `lowStockStream`: Productos con stock bajo
  - `dashboardStream`: Estadísticas combinadas
- **Características**:
  - Uso de `BehaviorSubject` para mantener último valor
  - Actualizaciones automáticas en todas las pantallas
  - Integración con sistema de notificaciones
  - Sin necesidad de recargar manualmente
  - Manejo de errores centralizado

## 📦 Dependencias Agregadas

```yaml
http: ^1.1.0 # API REST
flutter_local_notifications: ^17.0.0 # Notificaciones
google_maps_flutter: ^2.5.0 # Google Maps Android/iOS
google_maps_flutter_web: ^0.5.0 # Google Maps Web
geolocator: ^10.1.0 # Geolocalización
rxdart: ^0.27.7 # Streams avanzados
```

## 🔧 Configuración Necesaria

### Android (AndroidManifest.xml)

```xml
<!-- Permisos -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Google Maps API Key -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### iOS (Info.plist)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte en el mapa</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte en el mapa</string>
```

## 🎯 Uso de las Nuevas Funcionalidades

### Cotización del Dólar

```dart
// Se muestra automáticamente en HomeScreen
// Actualización manual con botón de refresh
final rate = await CurrencyService.instance.getExchangeRate();
```

### Notificaciones

```dart
// Automático al actualizar stock de productos
await NotificationService.instance.showCriticalStockNotification(
  productName: 'Producto X',
  currentStock: 3,
);
```

### Google Maps

```dart
// Navegar a la pantalla de mapas
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => MapsScreen()),
);
```

### Responsive UI

```dart
ResponsiveBuilder(
  builder: (context, deviceType) {
    return deviceType == DeviceType.mobile
        ? MobileLayout()
        : DesktopLayout();
  },
)

// O usando extension
if (context.isMobile) {
  // Layout para móvil
}
```

### Streams en Tiempo Real

```dart
// Escuchar cambios en productos
StreamService.instance.productosStream.listen((productos) {
  // Actualizar UI automáticamente
});

// Agregar producto (notifica a todos los listeners)
await StreamService.instance.addProducto(producto);
```

## 🌟 Mejoras Implementadas

1. **Performance**:

   - Cache de API REST (1 hora)
   - Streams con BehaviorSubject
   - Widgets optimizados con const

2. **UX/UI**:

   - Diseño responsive para todos los dispositivos
   - Animaciones suaves en mapas
   - Feedback visual inmediato
   - Notificaciones no intrusivas

3. **Arquitectura**:
   - Servicios singleton
   - Separación de responsabilidades
   - Manejo centralizado de errores
   - Código reutilizable

## 📱 Compatibilidad

| Funcionalidad  | Android | iOS | Web  | Desktop |
| -------------- | ------- | --- | ---- | ------- |
| API REST       | ✅      | ✅  | ✅   | ✅      |
| Notificaciones | ✅      | ✅  | ❌   | ❌      |
| Google Maps    | ✅      | ✅  | ✅\* | ❌      |
| Responsive UI  | ✅      | ✅  | ✅   | ✅      |
| Streams        | ✅      | ✅  | ✅   | ✅      |

\*Requiere google_maps_flutter_web configurado

## 🔑 API Keys Necesarias

1. **Google Maps**: https://console.cloud.google.com/

   - Habilitar Maps SDK for Android
   - Habilitar Maps SDK for iOS
   - Copiar API key al AndroidManifest.xml

2. **ExchangeRate API**: (Opcional - incluida)
   - API gratuita sin necesidad de key
   - Alternativa: https://openexchangerates.org/

## 🎨 Capturas de Pantalla

### Home con Cotización del Dólar

- Tarjeta morada con icono de dólar
- Actualización en tiempo real
- Botón de refresh manual

### Mapas con Ubicaciones

- Marcador azul: Oficina principal
- Marcadores rojos: Clientes
- Marcador verde: Tu ubicación
- Lista de ubicaciones debajo del mapa

### Notificaciones de Stock

- Notificación push cuando stock < 5
- Icono y color según prioridad
- Acción al tocar la notificación

## 🚀 Siguientes Pasos (Opcional)

- [ ] Gráficas con fl_chart
- [ ] Exportar reportes a PDF
- [ ] Chat con Firebase
- [ ] Sincronización en la nube
- [ ] Modo oscuro
- [ ] Multi-idioma (i18n)

## 📄 Licencia

MIT License - Uso educativo y comercial permitido
