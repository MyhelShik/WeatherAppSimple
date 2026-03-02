class WeatherInfo {
  final String city;
  final double temperature;
  final String description;
  final String mainCondition;
  final int humidity;
  final double windSpeed;
  final int timezone;
  final String iconCode; // Новое поле для иконки

  WeatherInfo({
    required this.city,
    required this.temperature,
    required this.description,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.timezone,
    required this.iconCode,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      mainCondition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      timezone: json['timezone'] ?? 0,
      iconCode: json['weather'][0]['icon'], // Парсим код иконки
    );
  }
}

class ForecastItem {
  final DateTime time;
  final double temperature;
  final String mainCondition;
  final String iconCode; // Новое поле для иконки прогноза

  ForecastItem({
    required this.time,
    required this.temperature,
    required this.mainCondition,
    required this.iconCode,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'], // Парсим код иконки
    );
  }
}

class FavoriteItem {
  String apiName;
  String nickname;
  String lastTemp;

  FavoriteItem({
    required this.apiName,
    required this.nickname,
    required this.lastTemp,
  });

  Map<String, dynamic> toJson() => {
        'apiName': apiName,
        'nickname': nickname,
        'lastTemp': lastTemp,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      apiName: json['apiName'],
      nickname: json['nickname'],
      lastTemp: json['lastTemp'],
    );
  }
}