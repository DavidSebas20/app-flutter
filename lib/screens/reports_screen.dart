import 'package:flutter/material.dart';

/// Pantalla de reportes de ventas
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reportes de Ventas', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),

              // Filtros de fecha
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filtrar por Fecha', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Seleccionar fecha inicio
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Fecha Inicio'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Seleccionar fecha fin
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Fecha Fin'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Generando reporte...')),
                            );
                          },
                          icon: const Icon(Icons.filter_list),
                          label: const Text('Aplicar Filtros'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resumen de ventas
              Text('Resumen del Período', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _ReportCard(
                      icon: Icons.attach_money,
                      label: 'Total Ventas',
                      value: '\$12,450.00',
                      color: Colors.green,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReportCard(
                      icon: Icons.shopping_cart,
                      label: 'Transacciones',
                      value: '45',
                      color: Colors.blue,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ReportCard(
                      icon: Icons.trending_up,
                      label: 'Promedio',
                      value: '\$276.67',
                      color: Colors.purple,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReportCard(
                      icon: Icons.star,
                      label: 'Top Producto',
                      value: 'Papel Bond',
                      color: Colors.orange,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Gráfico placeholder
              Card(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Gráfico de Ventas',
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Próximamente',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _ReportCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
