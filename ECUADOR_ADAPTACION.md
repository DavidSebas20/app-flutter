# 🇪🇨 Adaptación para Ecuador - Quito

## ✅ Cambios Realizados

Se ha adaptado completamente la aplicación para su uso en Ecuador, específicamente en Quito.

---

## 💵 Moneda y Cotización

### Antes (Colombia)

- Moneda: Peso Colombiano (COP)
- Cotización: USD → COP
- Formato: $4,850.25 COP

### Ahora (Ecuador)

- **Moneda**: Dólar Estadounidense (USD) - Moneda oficial de Ecuador
- **Cotización**: EUR → USD (referencia internacional)
- **Formato**: €1 = $1.0850 USD
- **Visualización**: Tarjeta morada en Home con símbolo € y $

### Archivos Modificados

- `lib/services/currency_service.dart`

  - API cambiada a EUR como base
  - Tasa EUR → USD
  - Comentarios actualizados para Ecuador

- `lib/screens/home_screen.dart`
  - Título: "Cotización EUR → USD"
  - Formato: €1 = $X.XXXX USD
  - Símbolo de euro (€) añadido

---

## 🗺️ Ubicaciones en Google Maps

### Coordenadas de Quito

**Oficina Principal** (Centro Histórico):

```
Latitud: -0.2201641
Longitud: -78.5123274
Ubicación: Centro Histórico de Quito
```

**Clientes Principales**:

1. **Cliente Norte - Quicentro**

   - Coordenadas: -0.1807, -78.4863
   - Dirección: Av. Naciones Unidas y Av. Amazonas
   - Zona: Norte de Quito (zona comercial)

2. **Cliente Sur - Quitumbe**

   - Coordenadas: -0.2891, -78.5458
   - Dirección: Av. Morán Valverde y Quitumbe Ñan
   - Zona: Sur de Quito (terminal terrestre)

3. **Cliente Centro - La Mariscal**

   - Coordenadas: -0.1925, -78.4875
   - Dirección: Av. Amazonas y Av. Patria
   - Zona: Centro-Norte (zona hotelera)

4. **Cliente Valle - Cumbayá**
   - Coordenadas: -0.2008, -78.4355
   - Dirección: Av. Interoceánica y San Juan Alto
   - Zona: Valle de Los Chillos (zona residencial)

### Archivo Modificado

- `lib/screens/maps_screen.dart`
  - Todas las coordenadas actualizadas
  - Direcciones reales de Quito
  - Nombres de zonas locales
  - Cobertura de 5km desde el centro

---

## 🌡️ Datos de Clima

### Actualizado para Quito

- **Ciudad**: Quito
- **Temperatura promedio**: 18.5°C (clima templado andino)
- **Descripción**: "Clima templado andino"
- **Altitud**: 2,850 metros sobre el nivel del mar

### Archivo Modificado

- `lib/services/currency_service.dart`
  - Método `getWeatherInfo()` con datos de Quito

---

## 🏢 Información de la Aplicación

### Actualizada en Splash Screen

- **Título**: "Distribuidora Quito"
- **Subtítulo**: "Productos de Oficina - Ecuador"
- **Ubicación**: Quito, Pichincha, Ecuador

### Archivo Modificado

- `lib/main.dart`
  - Título de la app actualizado
  - Texto del splash screen adaptado

---

## 📊 Formato de Moneda en Toda la App

Todos los precios y montos ahora se muestran en dólares estadounidenses:

- **Símbolo**: $
- **Formato**: $X,XXX.XX
- **Nombre**: USD
- **Decimales**: 2 dígitos

### Ejemplos:

- Precio de producto: $25.50
- Total de venta: $1,250.00
- Ingresos del día: $3,847.25

---

## 🎯 Funcionalidades Específicas para Ecuador

### 1. Cotización Internacional

- Muestra EUR → USD para referencia de comercio internacional
- Útil para importaciones desde Europa
- Actualización automática cada hora
- Formato con 4 decimales para precisión

### 2. Ubicaciones Estratégicas en Quito

- **Norte**: Zona comercial y empresarial
- **Sur**: Zona de transporte y logística
- **Centro**: Zona turística y hotelera
- **Valle**: Zona residencial y corporativa

### 3. Clima Andino

- Temperatura adaptada al clima de Quito (15-22°C)
- Descripción de clima templado de altura
- Referencia a condiciones andinas

---

## 📱 Cómo Usar la App en Quito

### 1. Iniciar la Aplicación

```bash
flutter run
```

### 2. Ver Cotización EUR → USD

- Abre la app
- En Home verás la tarjeta morada
- Muestra: €1 = $X.XXXX USD
- Click en 🔄 para actualizar

### 3. Explorar Mapa de Quito

- Ve a pestaña "Mapa"
- Verás oficina en Centro Histórico (marcador azul)
- 4 clientes en diferentes zonas (marcadores rojos)
- Tu ubicación actual (marcador verde)
- Click en marcadores para ver detalles

### 4. Registrar Ventas en USD

- Todos los precios en dólares
- Formato: $XX.XX
- Cálculos automáticos en USD

---

## 🔧 Personalización Adicional

### Cambiar Ubicación de Oficina

Edita `lib/screens/maps_screen.dart`:

```dart
// Pon tus coordenadas reales de Quito
static const LatLng _empresaLocation = LatLng(
  -0.XXXXXX,  // Tu latitud
  -78.XXXXXX, // Tu longitud
);
```

### Agregar Más Clientes

```dart
{
  'nombre': 'Nuevo Cliente',
  'ubicacion': const LatLng(-0.XXXX, -78.XXXX),
  'direccion': 'Dirección en Quito',
},
```

### Cambiar Ciudad en Clima

Si distribuyes en otra ciudad de Ecuador:

```dart
'city': 'Guayaquil', // o 'Cuenca', 'Ambato', etc.
'temperature': 26.5, // temperatura de la ciudad
```

---

## 🌍 Contexto de Ecuador

### Moneda Oficial

- Ecuador usa el **dólar estadounidense** desde el año 2000
- No tiene moneda propia
- Billetes y monedas de USD en circulación
- Cotización EUR → USD útil para importaciones

### Zonas de Quito

- **Norte**: Empresas, bancos, comercio
- **Centro**: Gobierno, turismo, historia
- **Sur**: Industrial, transporte
- **Valles**: Residencial, tecnología

### Altitud

- Quito está a **2,850 msnm**
- Segunda capital más alta del mundo
- Clima templado todo el año (15-22°C)
- "Eterna primavera"

---

## 📝 Resumen de Archivos Modificados

1. ✅ `lib/services/currency_service.dart` - EUR → USD
2. ✅ `lib/screens/home_screen.dart` - UI de cotización
3. ✅ `lib/screens/maps_screen.dart` - Ubicaciones de Quito
4. ✅ `lib/main.dart` - Título y splash
5. ✅ Documentación actualizada

---

## 🎉 Todo Listo para Ecuador

La aplicación está completamente adaptada para:

- ✅ Usar dólares estadounidenses (USD)
- ✅ Mostrar ubicaciones reales de Quito
- ✅ Cotización EUR → USD relevante
- ✅ Clima de Quito
- ✅ Contexto local ecuatoriano

**¡La app está lista para usarse en Quito, Ecuador!** 🇪🇨
