import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toothymate_app_4/views/welcome_screens.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final VoidCallback onLanguageSelected;

  const LanguageSelectionScreen({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/tooth_logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.health_and_safety, size: 100, color: Colors.white),
                ),
                const SizedBox(height: 40),

                const Text(
                  'Choose Your Language',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih Bahasa Anda',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 50),

                _buildLanguageButton(
                  context,
                  'English',
                  '🇺🇸',
                  const Locale('en'),
                ),
                const SizedBox(height: 20),
                _buildLanguageButton(
                  context,
                  'Bahasa Melayu',
                  '🇲🇾',
                  const Locale('ms'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String label, String flag, Locale locale) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        onPressed: () async {
          // Save language preference first
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('app_locale', locale.languageCode);

          // Store context before async gap
          if (!context.mounted) return;

          // Set locale
          await context.setLocale(locale);

          // Call the callback to notify parent
          onLanguageSelected();

          // Navigate to Onboarding Screen
          if (context.mounted) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}