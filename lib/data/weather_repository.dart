import '../models/weather.dart';
import 'weather_api_client.dart';

class CityNotFoundException implements Exception {}

class WeatherRepository {
  WeatherRepository(this._api);

  final WeatherApiClient _api;

  /// Сначала ищем координаты города, потом по ним берём прогноз.
  Future<Weather> getWeather(String cityName) async {
    final geo = await _api.searchCity(cityName);
    final results = geo['results'] as List?;
    if (results == null || results.isEmpty) throw CityNotFoundException();

    try {
      final city = City.fromJson(results.first as Map<String, dynamic>);
      final json = await _api.getForecast(city.latitude, city.longitude);
      return Weather.fromJson(city, json);
    } on WeatherException {
      rethrow;
    } catch (_) {
      throw WeatherException('Не удалось разобрать ответ сервера');
    }
  }
}
