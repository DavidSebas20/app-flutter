# 🗺️ Cambio a OpenStreetMap

## ¿Por qué OpenStreetMap?

Se ha cambiado de **Google Maps** a **OpenStreetMap** por las siguientes razones:

✅ **Completamente gratuito** - No requiere API key
✅ **Sin límites de uso** - No hay restricciones de consultas
✅ **No requiere facturación** - Sin tarjeta de crédito
✅ **Open Source** - Comunidad mundial de contribuidores

## Características Actuales

### 📍 Marcadores Implementados
- **Empresa Principal** (azul): Oficina en Centro Histórico de Quito
- **Clientes** (rojo): 4 ubicaciones principales en Quito:
  - Quicentro (Norte)
  - Quitumbe (Sur)
  - La Mariscal (Centro)
  - Cumbayá (Valle)
- **Tu ubicación** (verde): Cuando se otorgan permisos de ubicación

### 🎯 Funcionalidades
- Zoom interactivo
- Navegación por arrastre
- Lista de ubicaciones para navegación rápida
- Círculo de 5km alrededor de la oficina principal
- Botones de navegación rápida en el AppBar

## Tecnología Utilizada

### Paquetes
```yaml
flutter_map: ^6.1.0      # Widget de mapas
latlong2: ^0.9.0         # Coordenadas geográficas
geolocator: ^10.1.0      # Ubicación del dispositivo
```

### Proveedor de Tiles
- **OpenStreetMap**: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- Sin autenticación requerida
- Límite de uso justo (no hay hard limits)

## Notas Importantes

⚠️ **Política de Uso Justo de OpenStreetMap**
- No hacer más de 1 petición de tile por segundo
- Incluir un User-Agent identificable
- Para apps en producción con mucho tráfico, considera:
  - Hostear tus propios tiles
  - Usar servicios como Mapbox o Maptiler (tienen tier gratuito)

✨ **Sin costos ocultos**
- No se requiere configuración de billing en Google Cloud
- No hay riesgo de cargos inesperados
- Perfecto para desarrollo y demos

## Alternativas de Tiles Gratuitas

Si OpenStreetMap presenta problemas, puedes usar:

```dart
// Estilo claro
'https://tile.openstreetmap.org/{z}/{x}/{y}.png'

// Estilo humanitario
'https://tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'

// Transporte público
'https://tile.openstreetmap.org/hot/{z}/{x}/{y}.png'
```

## Personalización Futura

Para mejorar aún más:
- Agregar nombres a los marcadores con popups
- Implementar rutas entre puntos
- Agregar búsqueda de direcciones (geocoding gratuito)
- Temas de mapa personalizados
