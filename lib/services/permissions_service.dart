import 'package:permission_handler/permission_handler.dart';

/// Servicio para gestionar permisos de la aplicación
/// Valida acceso a internet, almacenamiento, notificaciones, etc.
class PermissionsService {
  // Singleton pattern
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal();

  /// Verifica si la app tiene acceso a internet
  /// En Flutter web y desktop, el acceso a internet no requiere permisos
  Future<bool> hasInternetPermission() async {
    // En móviles, verificar permiso de internet
    // En web y desktop, siempre retorna true
    return true;
  }

  /// Verifica y solicita permiso de almacenamiento
  Future<bool> requestStoragePermission() async {
    try {
      // SharedPreferences no requiere permisos especiales
      // pero si usamos archivos externos sí
      final status = await Permission.storage.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }

      return false;
    } catch (e) {
      // En plataformas que no requieren este permiso
      return true;
    }
  }

  /// Verifica y solicita permiso de notificaciones
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        // El usuario rechazó permanentemente, abrir configuración
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      // En plataformas que no requieren este permiso
      return true;
    }
  }

  /// Verifica y solicita permiso de ubicación
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.location.request();
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Solicita todos los permisos necesarios para la app
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    results['internet'] = await hasInternetPermission();
    results['storage'] = await requestStoragePermission();
    results['notifications'] = await requestNotificationPermission();
    results['location'] = await requestLocationPermission();

    return results;
  }

  /// Verifica el estado de todos los permisos
  Future<Map<String, bool>> checkAllPermissions() async {
    final results = <String, bool>{};

    results['internet'] = await hasInternetPermission();

    try {
      results['storage'] = (await Permission.storage.status).isGranted;
    } catch (e) {
      results['storage'] = true;
    }

    try {
      results['notifications'] =
          (await Permission.notification.status).isGranted;
    } catch (e) {
      results['notifications'] = true;
    }

    try {
      results['location'] = (await Permission.location.status).isGranted;
    } catch (e) {
      results['location'] = true;
    }

    return results;
  }

  /// Abre la configuración de la aplicación
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }
}
