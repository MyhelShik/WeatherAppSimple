import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

import 'weather_screen.dart';

Future<void> main() async {
  // Эта команда обязательна перед запуском Firebase!!!!!!!!
  WidgetsFlutterBinding.ensureInitialized();

  // загрузка env файла с ключиками
  // await dotenv.load(fileName: '.env');

  // --- ИНИЦИАЛИЗАЦИЯ FIREBASE ---
  // web + android
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: const WeatherScreen(), // нахуй стримбилдер
    );
  }
}