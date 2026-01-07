// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';       // Ensure this matches your filename
import 'welcome_screens.dart';    // Ensure this matches your filename

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // 1. Setup Animation (Pulse Effect)
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 2. Start the Timer to check login
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Wait 3 seconds just to show off the logo (Branding time!)
    await Future.delayed(const Duration(seconds: 3));

    // Check SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? userName = prefs.getString('user_name');

    if (!mounted) return;

    // Navigate to Home or Welcome
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => userName != null ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient Background
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
          ),
        ),
        child: Stack(
          children: [
            // --- CENTER CONTENT (Logo & App Name) ---
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/tooth_logo.png', 
                      height: 150,
                      errorBuilder: (c,e,s) => const Icon(Icons.face_retouching_natural, size: 100, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "ToothyMate",
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))]
                    ),
                  ),
                  const SizedBox(height: 50),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),

            // --- BOTTOM BRANDING (Client Name) ---
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    "In Collaboration with",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Text(
                      "Klinik Pergigian Dr. Karthi",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}