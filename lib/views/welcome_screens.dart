// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/sound_manager.dart';
import '../services/profile_service.dart';
import 'home_screen.dart';
import 'profile_selection_screen.dart'; 

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

// 3. FADE IN UP ANIMATION (For Onboarding Items)
class AnimateIn extends StatefulWidget {
  final Widget child;
  final int delay;
  final bool isVisible;

  const AnimateIn({super.key, required this.child, this.delay = 0, required this.isVisible});

  @override
  State<AnimateIn> createState() => _AnimateInState();
}

class _AnimateInState extends State<AnimateIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isVisible) _play();
  }

  @override
  void didUpdateWidget(AnimateIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _play();
      } else {
        _controller.reverse();
      }
    }
  }

  void _play() async {
    await Future.delayed(Duration(milliseconds: widget.delay));
    if (mounted && widget.isVisible) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

// ==========================================
// 🚀 SCREEN 1: ONBOARDING (Single Screen)
// ==========================================
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _finishOnboarding(BuildContext context) async {
    SoundManager.playPop();

    // Check if there's already an active profile (new profile flow)
    final activeProfile = ProfileService.getActiveProfile();

    if (activeProfile != null) {
      // New profile created - mark onboarding complete and go to Home
      await ProfileService.setBool('onboarding_complete', true);

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // First-time user - go to Profile Selection to create a profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // LOGO WITH GLOW EFFECT
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/tooth_logo.png',
                    height: 100,
                    width: 100,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.mood,
                      size: 80,
                      color: Color(0xFF0288D1),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // APP NAME & TAGLINE
                const Text(
                  'ToothyMate',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'welcomeSubtitle'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // FEATURES SECTION
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'whatYouCanDo'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FeatureRow(
                        icon: Icons.camera_alt_rounded,
                        color: const Color(0xFFE91E63),
                        text: 'aiToothScanner'.tr(),
                      ),
                      _FeatureRow(
                        icon: Icons.view_in_ar_rounded,
                        color: const Color(0xFF2196F3),
                        text: 'threeDMagicModels'.tr(),
                      ),
                      _FeatureRow(
                        icon: Icons.school_rounded,
                        color: const Color(0xFFFF9800),
                        text: 'smartELearning'.tr(),
                      ),
                      _FeatureRow(
                        icon: Icons.chat_bubble_rounded,
                        color: const Color(0xFF4CAF50),
                        text: 'aiDentalBuddy'.tr(),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // CTA BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _finishOnboarding(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'getStarted'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Feature Row Widget
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: color,
            size: 20,
          ),
        ],
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
      // Save user name with profile prefix
      await ProfileService.setString('user_name', _nameController.text.trim());

      // Init Stats if not exist
      if (ProfileService.getInt('user_xp') == null) {
        await ProfileService.setInt('user_xp', 0);
      }
      if (ProfileService.getInt('streak_count') == null) {
        await ProfileService.setInt('streak_count', 0);
      }

      if (!mounted) return;

      // Mark onboarding as complete for this profile
      await ProfileService.setBool('onboarding_complete', true);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
    } else {
      // Shake & Error Sound
      SoundManager.playPop();
      _shakeController.forward(from: 0);
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