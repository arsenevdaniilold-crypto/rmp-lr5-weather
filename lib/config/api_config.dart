/// Open-Meteo - бесплатный API, ключ не нужен.
/// Документация: https://open-meteo.com/en/docs
class ApiConfig {
  static const geocodingHost = 'geocoding-api.open-meteo.com';
  static const geocodingPath = '/v1/search';

  static const forecastHost = 'api.open-meteo.com';
  static const forecastPath = '/v1/forecast';

  static const forecastDays = 7;
  static const timeout = Duration(seconds: 10);
}
