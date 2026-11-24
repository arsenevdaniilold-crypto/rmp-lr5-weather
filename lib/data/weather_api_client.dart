import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class WeatherException implements Exception {
  WeatherException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WeatherApiClient {
  WeatherApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> searchCity(String name) {
    final uri = Uri.https(ApiConfig.geocodingHost, ApiConfig.geocodingPath, {
      'name': name,
      'count': '1',
      'language': 'ru',
      'format': 'json',
    });
    return _get(uri);
  }

  Future<Map<String, dynamic>> getForecast(double lat, double lon) {
    final uri = Uri.https(ApiConfig.forecastHost, ApiConfig.forecastPath, {
      'latitude': '$lat',
      'longitude': '$lon',
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'weather_code,wind_speed_10m,surface_pressure',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'wind_speed_unit': 'ms',
      'timezone': 'auto',
      'forecast_days': '${ApiConfig.forecastDays}',
    });
    return _get(uri);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw WeatherException('Сервер не отвечает');
    } catch (_) {
      throw WeatherException('Нет подключения к интернету');
    }

    if (response.statusCode == 404) {
      throw WeatherException('Данные не найдены (404)');
    }
    if (response.statusCode >= 500) {
      throw WeatherException(
        'Ошибка сервера (${response.statusCode}). Попробуйте позже',
      );
    }
    if (response.statusCode != 200) {
      throw WeatherException('Ошибка запроса (${response.statusCode})');
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw WeatherException('Некорректный ответ сервера');
    }
  }
}
