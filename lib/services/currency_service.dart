import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static final CurrencyService instance = CurrencyService._internal();
  factory CurrencyService() => instance;
  CurrencyService._internal();

  // API gratuita para tasas de cambio - Ecuador usa USD como moneda oficial
  // Mostramos EUR a USD para referencia internacional
  static const String _baseUrl =
      'https://api.exchangerate-api.com/v4/latest/EUR';

  double? _lastRate;
  DateTime? _lastUpdate;

  Future<Map<String, dynamic>> getExchangeRate() async {
    try {
      // Cache por 1 hora
      if (_lastRate != null && _lastUpdate != null) {
        final difference = DateTime.now().difference(_lastUpdate!);
        if (difference.inHours < 1) {
          return {
            'success': true,
            'rate': _lastRate!,
            'lastUpdate': _lastUpdate!,
            'fromCache': true,
          };
        }
      }

      final response = await http
          .get(Uri.parse(_baseUrl), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Tasa EUR a USD (Ecuador usa dólar estadounidense como moneda oficial)
        final rate = data['rates']['USD'] as num;
        _lastRate = rate.toDouble();
        _lastUpdate = DateTime.now();

        return {
          'success': true,
          'rate': _lastRate!,
          'lastUpdate': _lastUpdate!,
          'fromCache': false,
          'base': data['base'],
          'date': data['date'],
        };
      } else {
        return {
          'success': false,
          'error': 'Error al obtener cotización: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
        'rate': _lastRate,
        'lastUpdate': _lastUpdate,
      };
    }
  }

  // Método alternativo - datos de clima para Quito
  Future<Map<String, dynamic>> getWeatherInfo(String city) async {
    try {
      // API gratuita OpenWeatherMap (necesitas API key)
      // Por ahora retornamos datos simulados de Quito
      await Future.delayed(const Duration(seconds: 1));

      return {
        'success': true,
        'city': 'Quito',
        'temperature': 18.5,
        'description': 'Clima templado andino',
        'humidity': 65,
        'icon': '02d',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error al obtener clima: $e'};
    }
  }
}
