import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _selectedLocationIndex = 0;

  // Ubicaciones disponibles
  final List<Map<String, dynamic>> _locations = [
    {
      'nombre': 'Oficina Principal',
      'descripcion': 'Centro Histórico, Quito',
      'lat': -0.2201641,
      'lng': -78.5123274,
      'icon': Icons.business,
      'color': Colors.blue,
    },
    {
      'nombre': 'Cliente Norte - Quicentro',
      'descripcion': 'Av. Naciones Unidas y Av. Amazonas',
      'lat': -0.1807,
      'lng': -78.4863,
      'icon': Icons.store,
      'color': Colors.red,
    },
    {
      'nombre': 'Cliente Sur - Quitumbe',
      'descripcion': 'Av. Morán Valverde y Quitumbe Ñan',
      'lat': -0.2891,
      'lng': -78.5458,
      'icon': Icons.store,
      'color': Colors.red,
    },
    {
      'nombre': 'Cliente Centro - La Mariscal',
      'descripcion': 'Av. Amazonas y Av. Patria',
      'lat': -0.1925,
      'lng': -78.4875,
      'icon': Icons.store,
      'color': Colors.red,
    },
    {
      'nombre': 'Cliente Valle - Cumbayá',
      'descripcion': 'Av. Interoceánica y San Juan Alto',
      'lat': -0.2008,
      'lng': -78.4355,
      'icon': Icons.store,
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_getMapUrl(_selectedLocationIndex)));
  }

  String _getMapUrl(int index) {
    final location = _locations[index];
    final lat = location['lat'];
    final lng = location['lng'];
    // Usar OpenStreetMap alternativo que no requiere iframe
    return 'https://www.openstreetmap.org/export/embed.html?bbox=${lng - 0.01},${lat - 0.01},${lng + 0.01},${lat + 0.01}&layer=mapnik&marker=$lat,$lng';
  }

  void _goToLocation(int index) {
    setState(() {
      _selectedLocationIndex = index;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(_getMapUrl(index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.business),
            onPressed: () => _goToLocation(0),
            tooltip: 'Oficina principal',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mapa embebido
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          // Lista de ubicaciones
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  final isSelected = index == _selectedLocationIndex;
                  return _buildLocationTile(
                    location['nombre'] as String,
                    location['descripcion'] as String,
                    location['icon'] as IconData,
                    location['color'] as Color,
                    isSelected,
                    () => _goToLocation(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withOpacity(0.1) : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          isSelected ? Icons.location_on : Icons.navigate_next,
          color: isSelected ? color : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
