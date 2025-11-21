# 🚀 Quick Start - Ejecutar la Aplicación

## ⚡ Inicio Rápido (5 minutos)

### 1. Verificar Instalación

```bash
flutter doctor
```

Asegúrate de tener ✅ en Flutter, Android toolchain, y tu IDE.

### 2. Instalar Dependencias (si no lo has hecho)

```bash
cd "c:\Users\david\OneDrive\Documentos\Trabajo\Aplication Flutter\Aplication\app"
flutter pub get
```

### 3. Ejecutar en Emulador Android

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en el emulador
flutter run
```

### 4. Ejecutar en Web

```bash
flutter run -d chrome
```

---

## 🎯 Funcionalidades Listas para Probar

### ✅ Sin Configuración Adicional

1. **Cotización del Dólar** - Home Screen

   - Se carga automáticamente
   - Click en refresh para actualizar

2. **Sistema de Ventas** - Pestaña Ventas

   - Registra ventas
   - Actualización en tiempo real

3. **Inventario con Streams** - Pestaña Inventario

   - CRUD completo
   - Actualización automática

4. **UI Responsive**

   - Cambia orientación del dispositivo
   - Redimensiona ventana en Web

5. **Notificaciones Locales** - Android/iOS
   - Reduce stock de producto < 5
   - Verifica notificación push

### ⚠️ Requiere Configuración

6. **Google Maps** - Pestaña Mapa
   - Necesita API Key
   - Ver: `GOOGLE_MAPS_SETUP.md`

---

## 🧪 Flujo de Prueba Recomendado

### Paso 1: Login (2 min)

```
1. Abre la app
2. Click en "Crear cuenta"
3. Registra usuario: test@test.com / 123456
4. Inicia sesión
```

### Paso 2: Dashboard (1 min)

```
1. Verifica cotización del dólar (tarjeta morada)
2. Mira estadísticas en tiempo real
3. Pull-to-refresh para actualizar
```

### Paso 3: Inventario (2 min)

```
1. Ve a Inventario
2. Click en "+" para agregar producto
3. Nombre: "Producto Test", Cantidad: 4, Precio: 1000
4. Observa que la lista se actualiza automáticamente
```

### Paso 4: Notificaciones (2 min)

```
1. Con el producto de cantidad 4 creado
2. Ve a la campana (arriba derecha)
3. Verás alerta de stock crítico
4. Marca como leída
```

### Paso 5: Ventas (2 min)

```
1. Ve a Ventas
2. Selecciona un producto
3. Ingresa cantidad
4. Registra venta
5. Ve al Dashboard - verás actualización inmediata
```

### Paso 6: Responsive (1 min)

```
Android: Rota el dispositivo (Ctrl+F11/F12 en emulador)
Web: Redimensiona la ventana del navegador
Observa cómo el layout se adapta
```

### Paso 7: Maps (solo si configuraste API Key)

```
1. Ve a Mapa
2. Verás ubicación de empresa y clientes
3. Click en marcadores
4. Usa botones de navegación
```

---

## 🐛 Solución Rápida de Problemas

### Error: "SDK location not found"

```bash
# Crear local.properties en android/
echo "sdk.dir=C:\\Users\\TU_USUARIO\\AppData\\Local\\Android\\Sdk" > android/local.properties
```

### Error: "Gradle sync failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Notificaciones no aparecen

- Android 13+: Acepta permisos al inicio
- Verifica que el stock sea < 5
- No funciona en Web

### Mapa aparece en blanco

- Falta configurar Google Maps API Key
- Ver `GOOGLE_MAPS_SETUP.md`

### Cotización no carga

- Verifica conexión a internet
- Espera 10 segundos
- Click en botón refresh

---

## 📱 Atajos de Teclado (Emulador)

```
r     - Hot reload
R     - Hot restart
q     - Quit
p     - Show performance overlay
o     - Cycle platform (Android/iOS)
```

---

## 🎨 Usuarios de Prueba

Ya existen usuarios de muestra en la base de datos:

```
Email: admin@distribuidora.com
Password: admin123

Email: vendedor@distribuidora.com
Password: vendedor123
```

O crea tu propio usuario con "Crear cuenta".

---

## 📊 Datos de Prueba

La app se inicializa con:

- 5 productos de ejemplo
- Categorías: Papelería, Escritura, Archivo, Oficina, Marcadores
- Stock variado (algunos con stock bajo para probar notificaciones)

---

## 🎯 Checklist de Funcionalidades

Marca lo que has probado:

- [ ] Login/Registro
- [ ] Dashboard con estadísticas
- [ ] Cotización del dólar
- [ ] Agregar producto (Inventario)
- [ ] Editar producto
- [ ] Eliminar producto
- [ ] Búsqueda de productos
- [ ] Filtro por categoría
- [ ] Registrar venta
- [ ] Ver reportes
- [ ] Filtrar ventas por fecha
- [ ] Exportar reporte
- [ ] Notificaciones de stock bajo
- [ ] Badge de notificaciones
- [ ] Cambio de perfil
- [ ] Cerrar sesión
- [ ] UI responsive (rotar/redimensionar)
- [ ] Google Maps (requiere API Key)
- [ ] Pull-to-refresh
- [ ] Actualización en tiempo real

---

## 🚀 Comandos Útiles

```bash
# Ver dispositivos
flutter devices

# Ejecutar con logs detallados
flutter run -v

# Limpiar proyecto
flutter clean

# Reinstalar dependencias
flutter pub get

# Analizar código
flutter analyze

# Ver versión de Flutter
flutter --version

# Actualizar Flutter
flutter upgrade

# Compilar APK para Android
flutter build apk --release

# Compilar para Web
flutter build web
```

---

## 📸 Screenshots Automáticos

Para tomar screenshots:

```bash
# En emulador Android
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# O usa Ctrl+S en Android Studio mientras corre el emulador
```

---

## 🎉 Todo Listo!

La aplicación está completamente funcional.

**Documentación Completa**:

- `GUIA_DE_USO.md` - Manual completo
- `ADVANCED_FEATURES.md` - Detalles técnicos
- `GOOGLE_MAPS_SETUP.md` - Setup de Maps
- `RESUMEN_IMPLEMENTACION.md` - Estado del proyecto

**¿Problemas?** Revisa los archivos MD de documentación.

---

**Tiempo estimado de prueba completa**: 15-20 minutos
**Configuración de Google Maps**: +10 minutos (opcional)

¡Disfruta la app! 🚀
