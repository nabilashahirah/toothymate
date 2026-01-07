import 'package:flutter/material.dart';
import 'views/splash_screen.dart'; // Import your new splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToothyMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0288D1)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE1F5FE),
      ),
      // We start at the Splash Screen now!
      home: const SplashScreen(),
    );
  }
}