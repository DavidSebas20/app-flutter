import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';

/// Modelo de notificación
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool read;
  final String? actionRoute;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.read = false,
    this.actionRoute,
    this.data,
  });
}

enum NotificationType { lowStock, newSale, info, warning, success }

/// Pantalla de notificaciones
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      // Obtener productos con stock bajo
      final lowStockProducts = await _dbHelper.getProductosLowStock(10);

      // Obtener últimas ventas
      final recentSales = await _dbHelper.getAllVentas();
      final sortedSales = recentSales
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
      final last5Sales = sortedSales.take(5).toList();

      // Crear notificaciones
      final notifications = <AppNotification>[];

      // Notificación de bienvenida
      notifications.add(
        AppNotification(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          title: '¡Bienvenido!',
          message: 'Sistema de gestión de inventario y ventas activo',
          type: NotificationType.success,
          timestamp: DateTime.now(),
          read: false,
        ),
      );

      // Notificaciones de stock bajo
      for (var product in lowStockProducts) {
        notifications.add(
          AppNotification(
            id: 'lowstock_${product.id}',
            title: 'Stock Bajo: ${product.nombre}',
            message: 'Quedan solo ${product.cantidad} unidades disponibles',
            type: NotificationType.warning,
            timestamp: DateTime.now().subtract(
              Duration(hours: lowStockProducts.indexOf(product)),
            ),
            read: false,
            data: {'productId': product.id},
          ),
        );
      }

      // Notificaciones de ventas recientes
      for (var sale in last5Sales) {
        final product = await _dbHelper.getProductoById(sale.productoId);
        notifications.add(
          AppNotification(
            id: 'sale_${sale.id}',
            title: 'Nueva Venta Registrada',
            message:
                '${product?.nombre ?? "Producto"} - ${sale.cantidad} unidades - \$${sale.total.toStringAsFixed(2)}',
            type: NotificationType.newSale,
            timestamp: sale.fecha,
            read: true,
            data: {'saleId': sale.id},
          ),
        );
      }

      // Ordenar por fecha (más recientes primero)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar notificaciones: $e')),
        );
      }
    }
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          timestamp: _notifications[index].timestamp,
          read: true,
          actionRoute: _notifications[index].actionRoute,
          data: _notifications[index].data,
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map(
            (n) => AppNotification(
              id: n.id,
              title: n.title,
              message: n.message,
              type: n.type,
              timestamp: n.timestamp,
              read: true,
              actionRoute: n.actionRoute,
              data: n.data,
            ),
          )
          .toList();
    });
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:
        return Icons.inventory_2;
      case NotificationType.newSale:
        return Icons.shopping_cart;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.success:
        return Icons.check_circle_outline;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:
        return Colors.orange;
      case NotificationType.newSale:
        return Colors.blue;
      case NotificationType.info:
        return Colors.grey;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.success:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = _notifications.where((n) => !n.read).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Marcar todas como leídas'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay notificaciones',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: notification.read
                              ? null
                              : theme.colorScheme.primary.withOpacity(0.05),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getColorForType(
                                notification.type,
                              ).withOpacity(0.2),
                              child: Icon(
                                _getIconForType(notification.type),
                                color: _getColorForType(notification.type),
                              ),
                            ),
                            title: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.read
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(notification.message),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(notification.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: !notification.read
                                ? const Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: Colors.blue,
                                  )
                                : null,
                            onTap: () {
                              if (!notification.read) {
                                _markAsRead(notification.id);
                              }

                              // Mostrar detalles o realizar acción
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(notification.title),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(notification.message),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Fecha: ${dateFormat.format(notification.timestamp)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cerrar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
