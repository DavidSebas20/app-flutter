import 'package:flutter/material.dart';

/// Pantalla de mapa con ubicaciones
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Placeholder del mapa
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mapa de Ubicaciones',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Integración con Google Maps',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
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
            ),

            // Lista de ubicaciones
            Container(
              height: 200,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Ubicaciones', style: theme.textTheme.titleLarge),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            child: const Icon(Icons.business, color: Colors.white),
                          ),
                          title: const Text('Oficina Principal'),
                          subtitle: const Text('Av. Reforma 123, CDMX'),
                          trailing: IconButton(
                            icon: const Icon(Icons.directions),
                            onPressed: () {},
                          ),
                        ),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: const Icon(Icons.store, color: Colors.white),
                          ),
                          title: const Text('Cliente Premium'),
                          subtitle: const Text('Calle 5 de Mayo 456, CDMX'),
                          trailing: IconButton(
                            icon: const Icon(Icons.directions),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
