import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models.dart';

class WeatherApi {
  // адрес сервера Vercel
  static const String _baseUrl = 'https://weather-app-simple-sable.vercel.app/api';

  // Функция поиска городов
  static Future<List<dynamic>> searchCities(String query) async {
    if (query.length < 3) return [];

    try {
      // search.js
      final url = Uri.parse('$_baseUrl/search?query=$query');
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
      // колл к файлам weather.js и forecast.js
      final weatherUrl = Uri.parse('$_baseUrl/weather?city=$city');
      final forecastUrl = Uri.parse('$_baseUrl/forecast?city=$city');

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
    return null;
  }
}