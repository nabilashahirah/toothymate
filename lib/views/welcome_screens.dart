// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sound_manager.dart'; // Ensure this path matches your folder structure
import 'home_screen.dart'; 

// ==========================================
// 🎨 ANIMATION HELPERS (The "Juice")
// ==========================================

// 1. BREATHING WIDGET (Makes the mascot pulse)
class BreathingWidget extends StatefulWidget {
  final Widget child;
  const BreathingWidget({super.key, required this.child});

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}

// 2. ANIMATED BACKGROUND (Shifting Water Effect)
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});
  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat(reverse: true);
  }
  
  @override 
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF4FC3F7), const Color(0xFF29B6F6), _controller.value)!,
                const Color(0xFF0288D1),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

// ==========================================
// 🚀 SCREEN 1: ONBOARDING (Story & Info)
// ==========================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // 📝 CONTENT DATA
  final List<Map<String, dynamic>> _pages = [
    {
      // Screen 1: Core Problem
      "title": "onboardingTitle1",
      "body": "onboardingBody1",
      "image": "assets/images/kidbrush.png",
      "deco": "assets/images/question.png",
      "isFeatures": false,
    },
    {
      // Screen 2: How ToothyMate Helps
      "title": "onboardingTitle2",
      "body": "onboardingBody2",
      "image": "",
      "deco": null,
      "isFeatures": true,
    },
    {
      // Screen 3: Benefits
      "title": "onboardingTitle3",
      "body": "onboardingBody3",
      "image": "assets/images/happykids.png",
      "deco": null,
      "isFeatures": false,
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    SoundManager.playPop();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NameInputScreen()));
  }

  Widget _buildGradientCard({
    required String imagePath, 
    required String title, 
    required String subtitle, 
    required Gradient gradient
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: gradient, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
            child: Image.asset(
              imagePath, 
              height: 40,
              width: 40,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.2, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // SKIP BUTTON
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text("skip".tr(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ),
              ),

              // PAGE CONTENT
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    final bool isFeatures = page['isFeatures'] == true;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // --- IMAGE AREA ---
                          if (isFeatures)
                            Column(
                              children: [
                                _buildGradientCard(
                                  imagePath: 'assets/tooth_scan.png',
                                  title: 'aiToothScanner'.tr(), 
                                  subtitle: 'findsCavities'.tr(), 
                                  gradient: const LinearGradient(colors: [Color(0xFFBA68C8), Color(0xFFE91E63)]), 
                                ),
                                const SizedBox(height: 10),
                                _buildGradientCard(
                                  imagePath: 'assets/tooth_AR.png',
                                  title: 'threeDMagicModels'.tr(), 
                                  subtitle: 'seeInsideTooth'.tr(), 
                                  gradient: const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF009688)]), 
                                ),
                                const SizedBox(height: 10),
                                _buildGradientCard(
                                  imagePath: 'assets/tooth_edu.png',
                                  title: 'smartELearning'.tr(),  
                                  subtitle: 'includesGames'.tr(), 
                                  gradient: const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFFF9800)]), 
                                ),
                              ],
                            )
                          else
                            SizedBox(
                            height: 300,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Main Asset
                                Image.asset(page['image'], height: 250, errorBuilder: (c,e,s) => const Icon(Icons.image, size: 100, color: Colors.white54)),
                                
                                // Deco Asset (if any)
                                if (page['deco'] != null)
                                  Positioned(
                                    right: 0, top: 0,
                                    child: Image.asset(page['deco'], height: 80, errorBuilder: (c,e,s) => const SizedBox()),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // --- TEXT ---
                          Text(
                            page['title'].toString().tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            page['body'].toString().tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // BOTTOM CONTROLS
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 10,
                        width: _currentPage == index ? 30 : 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.orange : Colors.white54,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      )),
                    ),
                    const SizedBox(height: 20),
                    
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          SoundManager.playPop();
                          _nextPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? "getStarted".tr() + " 🚀" : "next".tr() + " ➡️",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 🚀 SCREEN 2: NAME INPUT (Enhanced!)
// ==========================================
class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  String _displayName = "Hero"; // For Dynamic Greeting
  
  // Shake Animation Variables
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    // Setup Shake
    _shakeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    // Listen to typing for Dynamic Greeting
    _nameController.addListener(() {
      setState(() {
        _displayName = _nameController.text.trim().isEmpty ? "Hero" : _nameController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_nameController.text.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());
      
      // Init Stats
      if (prefs.getInt('user_xp') == null) await prefs.setInt('user_xp', 0);
      if (prefs.getInt('streak_count') == null) await prefs.setInt('streak_count', 0);
      
      if (!mounted) return;

      // Mark onboarding as complete
      await prefs.setBool('onboarding_complete', true);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
    } else {
      // ❌ JUICE: Shake & Error Sound
      SoundManager.playPop(); 
      _shakeController.forward(from: 0); // Trigger Shake
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('oopsForgotName'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0288D1),
      resizeToAvoidBottomInset: true,
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Hero(tag: 'mascot', child: Icon(Icons.face_retouching_natural, size: 90, color: Colors.white)),
                    const SizedBox(height: 25),
                    
                    // --- JUICE: Dynamic Greeting ---
                    Text(
                      "${'hello'.tr()}, $_displayName!", 
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)
                    ),
                    const SizedBox(height: 10),
                    Text('typeYourName'.tr(), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 30),
                    
                    // --- JUICE: Shake Animation ---
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: TextField(
                        controller: _nameController,
                        autofocus: true,
                        style: const TextStyle(fontSize: 20, color: Color(0xFF0277BD), fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'yourName'.tr(),
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          prefixIcon: const Icon(Icons.person_rounded, color: Colors.orangeAccent),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          SoundManager.playPop();
                          _handleContinue();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 5
                        ),
                        child: Text("${'letsGo'.tr()} 🚀", style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}