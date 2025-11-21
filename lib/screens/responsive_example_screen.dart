import 'package:flutter/material.dart';
import '../widgets/responsive_builder.dart';

/// Ejemplo de pantalla responsive adaptativa
/// Muestra cómo usar los widgets responsive en tu aplicación
class ResponsiveExampleScreen extends StatelessWidget {
  const ResponsiveExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo Responsive')),
      body: ResponsiveContainer(
        maxWidth: 1200,
        child: ResponsivePadding(
          mobile: const EdgeInsets.all(8),
          tablet: const EdgeInsets.all(16),
          desktop: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título responsive
                ResponsiveText(
                  'Dashboard',
                  mobileFontSize: 24,
                  tabletFontSize: 32,
                  desktopFontSize: 40,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Grid responsive
                ResponsiveBuilder(
                  builder: (context, deviceType) {
                    // Diferentes columnas según dispositivo
                    final columns = switch (deviceType) {
                      DeviceType.mobile => 1,
                      DeviceType.tablet => 2,
                      DeviceType.desktop => 3,
                    };

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return _ExampleCard(index: index);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Layout diferente por dispositivo
                ResponsiveBuilder.custom(
                  mobile: _MobileLayout(),
                  tablet: _TabletLayout(),
                  desktop: _DesktopLayout(),
                ),
                const SizedBox(height: 24),

                // Información del dispositivo actual
                _DeviceInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final int index;

  const _ExampleCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: context.isMobile ? 32 : 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              'Card ${index + 1}',
              mobileFontSize: 14,
              tabletFontSize: 16,
              desktopFontSize: 18,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ResponsiveText(
              'Información',
              mobileFontSize: 12,
              tabletFontSize: 14,
              desktopFontSize: 16,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Layout para móvil (vertical)
class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.phone_android, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Layout Móvil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Diseño optimizado para pantallas pequeñas',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Layout para tablet (dos columnas)
class _TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.tablet, size: 64, color: Colors.green),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layout Tablet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Diseño con dos columnas para aprovechar el espacio',
                    style: TextStyle(color: Colors.grey[600]),
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

// Layout para desktop (tres columnas)
class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(Icons.computer, size: 80, color: Colors.purple),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layout Desktop',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Diseño expansivo para pantallas grandes con más información visible',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Ver más'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tarjeta con información del dispositivo
class _DeviceInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    final width = context.screenWidth;
    final height = context.screenHeight;

    final deviceName = switch (deviceType) {
      DeviceType.mobile => 'Móvil',
      DeviceType.tablet => 'Tablet',
      DeviceType.desktop => 'Desktop',
    };

    final deviceColor = switch (deviceType) {
      DeviceType.mobile => Colors.blue,
      DeviceType.tablet => Colors.green,
      DeviceType.desktop => Colors.purple,
    };

    return Card(
      color: deviceColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: deviceColor),
                const SizedBox(width: 8),
                Text(
                  'Información del Dispositivo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: deviceColor,
                  ),
                ),
              ],
            ),
            const Divider(),
            _InfoRow('Tipo', deviceName, deviceColor),
            _InfoRow('Ancho', '${width.toStringAsFixed(0)}px', deviceColor),
            _InfoRow('Alto', '${height.toStringAsFixed(0)}px', deviceColor),
            _InfoRow(
              'Breakpoint',
              deviceType == DeviceType.mobile
                  ? '< 600px'
                  : deviceType == DeviceType.tablet
                  ? '600-900px'
                  : '> 900px',
              deviceColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
