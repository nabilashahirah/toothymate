import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:toothymate_app_4/views/language_selection_screen.dart';
import 'package:toothymate_app_4/views/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds then check if onboarding is complete
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
      final String? savedLocale = prefs.getString('app_locale');

      // Restore saved language if exists
      if (savedLocale != null && mounted) {
        await context.setLocale(Locale(savedLocale));
      }

      if (!mounted) return;

      if (onboardingComplete) {
        // User has completed onboarding, go directly to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // First time user, show language selection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LanguageSelectionScreen(
              onLanguageSelected: () {
                debugPrint("Language Selected! Navigate to Onboarding.");
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4FC3F7), // Light blue
              Color(0xFF29B6F6), // Medium blue
              Color(0xFF0288D1), // Dark blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/animation/tooth_animation.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
              const SizedBox(height: 20),
              // App Name
              const Text(
                'ToothyMate',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Dental Care Companion',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              // Collaboration text
              Text(
                'collaboration'.tr(),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'clinicName'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // Loading Indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}