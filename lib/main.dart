import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'services/firebase_service.dart';
import 'views/splash_screen.dart'; // Import your new splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  print('🚀 APP: Starting Firebase initialization...');

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('🚀 APP: Firebase.initializeApp() SUCCESS');
  } catch (e) {
    print('🚀 APP: Firebase.initializeApp() ERROR: $e');
  }

  // Initialize Firebase Service (Anonymous Auth)
  await FirebaseService().init();

  print('🚀 APP: Firebase setup complete, starting app...');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ms')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToothyMate',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
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