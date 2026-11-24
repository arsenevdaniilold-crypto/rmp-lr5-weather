class City {
  City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String,
      country: (json['country'] as String?) ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class CurrentWeather {
  CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressureMm,
    required this.weatherCode,
  });

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int? pressureMm;
  final int weatherCode;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final pressure = json['surface_pressure'] as num?;
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      feelsLike: (json['apparent_temperature'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).round(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      // гПа -> мм рт. ст.
      pressureMm: pressure == null ? null : (pressure * 0.750062).round(),
      weatherCode: (json['weather_code'] as num).toInt(),
    );
  }
}

class DailyForecast {
  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherCode,
  });

  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final int weatherCode;
}

class Weather {
  Weather({required this.city, required this.current, required this.daily});

  final City city;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  factory Weather.fromJson(City city, Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>;
    final dates = daily['time'] as List;
    final codes = daily['weather_code'] as List;
    final maxT = daily['temperature_2m_max'] as List;
    final minT = daily['temperature_2m_min'] as List;

    final days = <DailyForecast>[];
    for (var i = 0; i < dates.length; i++) {
      days.add(
        DailyForecast(
          date: DateTime.parse(dates[i] as String),
          minTemp: (minT[i] as num).toDouble(),
          maxTemp: (maxT[i] as num).toDouble(),
          weatherCode: (codes[i] as num).toInt(),
        ),
      );
    }

    return Weather(
      city: city,
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      daily: days,
    );
  }
}
