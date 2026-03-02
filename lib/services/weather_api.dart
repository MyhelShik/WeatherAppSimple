import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models.dart';

class WeatherApi {
  // Получаем ключ из .env файла
  static String get _apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  // Функция поиска городов
  static Future<List<dynamic>> searchCities(String query) async {
    if (query.length < 3) return [];

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=8&appid=$_apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final uniqueCities = <String>{};
        final filteredList = <dynamic>[];

        for (var city in data) {
          final String name = city['name'];
          final String country = city['country'];
          final String state = city['state'] ?? '';

          final String key = '${name.toLowerCase()}|${country.toLowerCase()}|${state.toLowerCase()}';

          if (!uniqueCities.contains(key)) {
            uniqueCities.add(key);
            filteredList.add(city);
          }
        }
        return filteredList;
      }
    } catch (e) {
      print('Search API Error: $e');
    }
    return [];
  }

  // Функция получения полной погоды и прогноза
  static Future<Map<String, dynamic>?> fetchFullWeather(String city) async {
    try {
      final weatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric',
      );
      final forecastUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$_apiKey&units=metric',
      );

      final weatherRes = await http.get(weatherUrl);
      final forecastRes = await http.get(forecastUrl);

      if (weatherRes.statusCode == 200 && forecastRes.statusCode == 200) {
        final weatherData = jsonDecode(weatherRes.body);
        final forecastData = jsonDecode(forecastRes.body);

        final currentWeather = WeatherInfo.fromJson(weatherData);
        final List<dynamic> list = forecastData['list'];
        final forecast = list.map((item) => ForecastItem.fromJson(item)).toList();

        return {
          'weather': currentWeather,
          'forecast': forecast,
        };
      }
    } catch (e) {
      print('Weather API Error: $e');
    }
    return null; // Возвращаем null, если город не найден или ошибка
  }
}