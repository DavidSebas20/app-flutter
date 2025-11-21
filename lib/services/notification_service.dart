import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show Color;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb) return; // No soportado en Web
    if (_initialized) return;

    try {
      // Configuración Android
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // Configuración iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Manejar cuando el usuario toca la notificación
          print('Notification clicked: ${response.payload}');
        },
      );

      // Solicitar permisos
      await _requestPermissions();

      _initialized = true;
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    try {
      if (!kIsWeb && Platform.isAndroid) {
        // Android 13+ requiere permisos de notificación
        // Por ahora solo solicitamos al inicializar
        print(
          'Android notification permissions will be requested on first use',
        );
      }

      if (!kIsWeb && Platform.isIOS) {
        await _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  Future<void> showLowStockNotification({
    required String productName,
    required int currentStock,
  }) async {
    if (kIsWeb || !_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Stock Bajo',
      channelDescription: 'Notificaciones de productos con stock bajo',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF6B35),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        currentStock.hashCode, // ID único basado en el stock
        '⚠️ Stock Bajo',
        '$productName: Solo quedan $currentStock unidades',
        details,
        payload: 'low_stock:$productName',
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> showCriticalStockNotification({
    required String productName,
    required int currentStock,
  }) async {
    if (kIsWeb || !_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'critical_stock_channel',
      'Stock Crítico',
      channelDescription: 'Notificaciones de productos con stock crítico',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFD32F2F),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        productName.hashCode, // ID único basado en el nombre
        '🚨 ¡Stock Crítico!',
        '$productName está por agotarse. Stock actual: $currentStock unidades',
        details,
        payload: 'critical_stock:$productName',
      );
    } catch (e) {
      print('Error showing critical notification: $e');
    }
  }

  Future<void> checkProductStock({
    required String productName,
    required int currentStock,
    required int previousStock,
  }) async {
    // Solo notificar cuando cruza el umbral
    if (currentStock < 5 && previousStock >= 5) {
      await showCriticalStockNotification(
        productName: productName,
        currentStock: currentStock,
      );
    } else if (currentStock < 10 && previousStock >= 10) {
      await showLowStockNotification(
        productName: productName,
        currentStock: currentStock,
      );
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb || !_initialized) return;
    await _notifications.cancel(id);
  }
}
