import 'package:flutter/material.dart';

import 'data/weather_api_client.dart';
import 'data/weather_repository.dart';
import 'screens/weather_screen.dart';
import 'state/weather_state.dart';

void main() {
  final repository = WeatherRepository(WeatherApiClient());
  runApp(WeatherApp(state: WeatherState(repository)));
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key, required this.state});

  final WeatherState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Погода',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.lightBlue,
        useMaterial3: true,
        fontFamily: 'GolosText',
      ),
      home: WeatherScreen(state: state),
    );
  }
}
