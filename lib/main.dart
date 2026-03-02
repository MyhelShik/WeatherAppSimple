import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Нужно для проверки: Web или Android
import 'package:firebase_core/firebase_core.dart'; // Ядро Firebase
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Твои секретные ключи



import 'weather_screen.dart';

Future<void> main() async {
  // Эта команда обязательна перед запуском Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем ключи OpenWeather (твой .env файл)
  await dotenv.load(fileName: '.env');

  // --- УМНАЯ ИНИЦИАЛИЗАЦИЯ FIREBASE ---
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Weather',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1F1C2C),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Roboto')),
      ),
      home: const WeatherScreen(), // Убираем StreamBuilder отсюда
    );
  }
}
