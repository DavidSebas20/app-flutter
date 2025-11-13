import 'package:flutter/material.dart';

/// Pantalla de registro de ventas
class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registrar Nueva Venta', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),

              // Formulario de venta
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Seleccionar Producto',
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('Papel Bond Tamaño Carta')),
                          DropdownMenuItem(value: '2', child: Text('Bolígrafos Azules Caja 12')),
                          DropdownMenuItem(value: '3', child: Text('Carpetas Tamaño Carta')),
                        ],
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Venta registrada exitosamente'), backgroundColor: Colors.green),
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Registrar Venta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Últimas ventas
              Text('Últimas Ventas', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.shopping_cart, color: theme.colorScheme.primary),
                        ),
                        title: Text('Venta #${1000 + index}'),
                        subtitle: Text('Hace ${index + 1} hora${index > 0 ? 's' : ''}'),
                        trailing: Text(
                          '\$${(500 + index * 150).toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
