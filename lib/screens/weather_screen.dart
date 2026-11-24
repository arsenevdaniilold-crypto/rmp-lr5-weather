import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../state/weather_state.dart';
import '../utils/weather_codes.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key, required this.state});

  final WeatherState state;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();

  WeatherState get state => widget.state;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _search([String? city]) {
    if (city != null) _cityController.text = city;
    FocusScope.of(context).unfocus();
    state.search(_cityController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Погода')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _cityController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Город, например Москва',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: state.status == WeatherStatus.loading
                        ? null
                        : () => _search(),
                  ),
                ),
              ),
              // избранные города (доп. задание)
              if (state.favorites.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final city in state.favorites)
                      ActionChip(
                        label: Text(city),
                        onPressed: () => _search(city),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _buildBody(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (state.status) {
      case WeatherStatus.initial:
        return const _Message(
          text: 'Введите название города, чтобы узнать погоду',
        );
      case WeatherStatus.loading:
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        );
      case WeatherStatus.notFound:
        return _Message(
          icon: Icons.search_off,
          text: 'Город «${state.lastQuery}» не найден',
        );
      case WeatherStatus.error:
        return _Message(
          icon: Icons.cloud_off,
          text: state.errorMessage ?? 'Ошибка',
          action: state.lastQuery.isEmpty
              ? null
              : FilledButton.icon(
                  onPressed: state.retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                ),
        );
      case WeatherStatus.success:
        final w = state.weather!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _currentCard(context, w),
            const SizedBox(height: 16),
            Text(
              'Прогноз на ${w.daily.length} дней',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final day in w.daily) _forecastTile(day),
          ],
        );
    }
  }

  Widget _currentCard(BuildContext context, Weather w) {
    final theme = Theme.of(context);
    final c = w.current;
    final cityTitle = w.city.country.isEmpty
        ? w.city.name
        : '${w.city.name}, ${w.city.country}';

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(cityTitle, style: theme.textTheme.titleLarge),
                ),
                IconButton(
                  tooltip: 'В избранное',
                  icon: Icon(
                    state.isFavorite(w.city.name)
                        ? Icons.star
                        : Icons.star_border,
                  ),
                  onPressed: () => state.toggleFavorite(w.city.name),
                ),
              ],
            ),
            Icon(
              weatherIcon(c.weatherCode),
              size: 72,
              color: weatherColor(c.weatherCode),
            ),
            Text(
              '${c.temperature.round()}°C',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              weatherDescription(c.weatherCode),
              style: theme.textTheme.titleMedium,
            ),
            Text('Ощущается как ${c.feelsLike.round()}°C'),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 16,
              runSpacing: 12,
              children: [
                _Indicator(
                  icon: Icons.water_drop_outlined,
                  label: 'Влажность',
                  value: '${c.humidity}%',
                ),
                _Indicator(
                  icon: Icons.air,
                  label: 'Ветер',
                  value: '${c.windSpeed.toStringAsFixed(1)} м/с',
                ),
                if (c.pressureMm != null)
                  _Indicator(
                    icon: Icons.speed,
                    label: 'Давление',
                    value: '${c.pressureMm} мм',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  Widget _forecastTile(DailyForecast day) {
    final d = day.date;
    final date =
        '${_weekdays[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        leading: Icon(
          weatherIcon(day.weatherCode),
          color: weatherColor(day.weatherCode),
        ),
        title: Text(date),
        subtitle: Text(weatherDescription(day.weatherCode)),
        trailing: Text(
          '${day.minTemp.round()}° / ${day.maxTemp.round()}°',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({this.icon, required this.text, this.action});

  final IconData? icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
          ],
          Text(text, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
