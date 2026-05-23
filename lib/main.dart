import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SpeakNationApp());
}

class SpeakNationApp extends StatelessWidget {
  const SpeakNationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeakNation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFB00020),
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB00020),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB00020),
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB00020),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}