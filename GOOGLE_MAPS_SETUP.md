# Configuración de Google Maps API

## ⚠️ IMPORTANTE: Configuración Requerida

Para que el mapa funcione correctamente, necesitas obtener una API Key de Google Maps.

## 📋 Pasos para Obtener la API Key

### 1. Ir a Google Cloud Console

Visita: https://console.cloud.google.com/

### 2. Crear un Proyecto (si no tienes uno)

- Click en el menú desplegable de proyectos (arriba izquierda)
- Click en "Nuevo Proyecto"
- Nombre: "Distribuidora App" (o el que prefieras)
- Click en "Crear"

### 3. Habilitar APIs Necesarias

Busca y habilita las siguientes APIs:

- **Maps SDK for Android** (para Android)
- **Maps SDK for iOS** (para iOS)
- **Maps JavaScript API** (para Web)

Para habilitar:

- Ve a "APIs y servicios" > "Biblioteca"
- Busca cada API
- Click en "Habilitar"

### 4. Crear Credenciales (API Key)

- Ve a "APIs y servicios" > "Credenciales"
- Click en "+ CREAR CREDENCIALES"
- Selecciona "Clave de API"
- Copia la clave generada

### 5. Configurar Restricciones (Recomendado)

Para seguridad, restringe tu API key:

**Para Android:**

- Click en tu API key
- En "Restricciones de aplicación", selecciona "Aplicaciones de Android"
- Click en "Agregar un nombre de paquete y huella digital"
- Nombre del paquete: `com.example.app` (o el tuyo en build.gradle)
- Para obtener la huella SHA-1:
  ```bash
  cd android
  ./gradlew signingReport
  ```

**Para iOS:**

- Selecciona "Aplicaciones de iOS"
- Agrega el Bundle ID de tu app

## 🔧 Configurar en tu Aplicación

### Android

Edita: `android/app/src/main/AndroidManifest.xml`

Reemplaza `YOUR_API_KEY_HERE` con tu API key real:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

### iOS

Edita: `ios/Runner/AppDelegate.swift`

Agrega al inicio del método `application`:

```swift
import UIKit
import Flutter
import GoogleMaps  // Agregar

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("TU_API_KEY_AQUI")  // Agregar
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

Y en `ios/Podfile` descomenta o agrega:

```ruby
platform :ios, '13.0'
```

### Web

Edita: `web/index.html`

Agrega antes de `</head>`:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=TU_API_KEY_AQUI"></script>
```

## 🧪 Probar la Configuración

1. Limpia y reconstruye el proyecto:

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. Navega a la sección "Mapa" en la app

3. Verifica que:
   - El mapa se carga correctamente
   - Aparecen los marcadores (empresa y clientes)
   - Funciona la ubicación actual

## ⚠️ Solución de Problemas

### Error: "Google Maps SDK initialization"

- Verifica que la API key esté correctamente copiada (sin espacios)
- Asegúrate de haber habilitado las APIs necesarias
- Espera 5-10 minutos después de crear/modificar la key

### El mapa aparece gris

- La API key puede estar restringida incorrectamente
- Temporalmente, quita las restricciones para probar

### Error de permisos de ubicación

La app solicitará permisos automáticamente, pero verifica que:

**Android (AndroidManifest.xml):**

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS (Info.plist):**

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte en el mapa</string>
```

## 💡 Consejos

1. **Facturación**: Google Maps requiere cuenta de facturación, pero tiene $200 USD de crédito gratis mensual (suficiente para desarrollo y uso moderado)

2. **Cuota Gratuita**: ~28,000 cargas de mapa por mes gratis

3. **Seguridad**: NUNCA subas tu API key a repositorios públicos. Usa variables de entorno en producción.

4. **Alternativa Sin API Key**:
   - Puedes comentar temporalmente la pantalla de mapas
   - O usar un mapa estático con una imagen

## 📍 Personalizar Ubicaciones

Edita `lib/screens/maps_screen.dart`:

```dart
// Ubicación de tu empresa en Quito, Ecuador
static const LatLng _empresaLocation = LatLng(-0.2201641, -78.5123274);

// Agrega/modifica clientes en Quito
final List<Map<String, dynamic>> _clientes = [
  {
    'nombre': 'Cliente Norte - Quicentro',
    'ubicacion': const LatLng(-0.1807, -78.4863),
    'direccion': 'Av. Naciones Unidas y Amazonas',
  },
  // ... más clientes
];
```

## 🎯 Próximos Pasos

Una vez configurado, puedes:

- Agregar más marcadores dinámicamente desde la base de datos
- Calcular rutas entre ubicaciones
- Mostrar áreas de cobertura
- Agregar heat maps de ventas por zona

## 📞 Soporte

Si tienes problemas:

1. Revisa la consola de Google Cloud por errores
2. Verifica los logs de Flutter (`flutter run -v`)
3. Asegúrate de tener conexión a internet

---

**Nota**: Sin la API key configurada, la pantalla de mapas mostrará un error o un mapa en blanco. Todas las demás funcionalidades de la app funcionarán normalmente.
