import 'package:flutter/foundation.dart';

import '../data/weather_api_client.dart';
import '../data/weather_repository.dart';
import '../models/weather.dart';

enum WeatherStatus { initial, loading, success, notFound, error }

class WeatherState extends ChangeNotifier {
  WeatherState(this._repository);

  final WeatherRepository _repository;

  WeatherStatus status = WeatherStatus.initial;
  Weather? weather;
  String? errorMessage;
  String lastQuery = '';

  /// Избранные города (доп. задание)
  final List<String> favorites = [];

  Future<void> search(String query) async {
    final city = query.trim();
    if (city.isEmpty) {
      status = WeatherStatus.error;
      errorMessage = 'Введите название города';
      notifyListeners();
      return;
    }

    lastQuery = city;
    status = WeatherStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      weather = await _repository.getWeather(city);
      status = WeatherStatus.success;
    } on CityNotFoundException {
      status = WeatherStatus.notFound;
    } on WeatherException catch (e) {
      status = WeatherStatus.error;
      errorMessage = e.message;
    }
    notifyListeners();
  }

  Future<void> retry() => search(lastQuery);

  bool isFavorite(String city) => favorites.contains(city);

  void toggleFavorite(String city) {
    if (favorites.contains(city)) {
      favorites.remove(city);
    } else {
      favorites.add(city);
    }
    notifyListeners();
  }
}
