import 'package:flutter/material.dart';

/// Коды погоды WMO, которые возвращает Open-Meteo.
String weatherDescription(int code) {
  switch (code) {
    case 0:
      return 'Ясно';
    case 1:
      return 'Преимущественно ясно';
    case 2:
      return 'Переменная облачность';
    case 3:
      return 'Пасмурно';
    case 45:
    case 48:
      return 'Туман';
    case 51:
    case 53:
    case 55:
      return 'Морось';
    case 56:
    case 57:
      return 'Ледяная морось';
    case 61:
    case 63:
    case 65:
      return 'Дождь';
    case 66:
    case 67:
      return 'Ледяной дождь';
    case 71:
    case 73:
    case 75:
    case 77:
      return 'Снег';
    case 80:
    case 81:
    case 82:
      return 'Ливень';
    case 85:
    case 86:
      return 'Снегопад';
    case 95:
    case 96:
    case 99:
      return 'Гроза';
    default:
      return 'Нет данных';
  }
}

IconData weatherIcon(int code) {
  if (code == 0 || code == 1) return Icons.wb_sunny_rounded;
  if (code == 2) return Icons.wb_cloudy_rounded;
  if (code == 3) return Icons.cloud_rounded;
  if (code == 45 || code == 48) return Icons.foggy;
  if (code >= 51 && code <= 57) return Icons.grain_rounded;
  if (code >= 61 && code <= 67) return Icons.umbrella_rounded;
  if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
  if (code >= 80 && code <= 82) return Icons.umbrella_rounded;
  if (code == 85 || code == 86) return Icons.cloudy_snowing;
  if (code >= 95) return Icons.thunderstorm_rounded;
  return Icons.help_outline_rounded;
}

/// Цвет значка погоды: солнце оранжевое, снег голубой, гроза фиолетовая
Color weatherColor(int code) {
  if (code == 0 || code == 1) return Colors.orange;
  if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
    return Colors.lightBlue;
  }
  if (code >= 95) return Colors.deepPurple;
  return Colors.blueGrey;
}
