// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground( // <--- JUICE: Moving Water
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                
                // --- BREATHING MASCOT ---
                Hero(
                  tag: 'mascot',
                  child: BreathingWidget( // <--- JUICE: Breathing
                    child: Image.asset(
                      'assets/tooth_logo.png', 
                      height: 190, 
                      errorBuilder: (c,e,s) => const Icon(Icons.face_retouching_natural, size: 150, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // --- TITLE ---
                const Text(
                  'ToothyMate', 
                  style: TextStyle(
                    fontSize: 45, fontWeight: FontWeight.w900, color: Colors.white,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]
                  )
                ),
                
                const SizedBox(height: 30),

                // --- INFO CARD (With Client Integration) ---
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "Dr. Karthi Needs You! 🦸‍♂️", // <--- CLIENT BRANDING
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0288D1)),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Join Klinik Pergigian Dr. Karthi's mission to fight Sugar Bugs! Use AI to scan your teeth and keep your smile shining.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
                
                // --- BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {
                      SoundManager.playPop(); // <--- JUICE: Sound
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NameInputScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: Colors.orangeAccent,
                    ),
                    child: const Text('Get Started 🚀', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
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

      Navigator.push(context, MaterialPageRoute(builder: (context) => const FeatureShowcaseScreen()));
    } else {
      // ❌ JUICE: Shake & Error Sound
      SoundManager.playPop(); 
      _shakeController.forward(from: 0); // Trigger Shake
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Oops! You forgot your name!", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
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
                      "Hello, $_displayName!", 
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)
                    ),
                    const SizedBox(height: 10),
                    const Text("Type your name below:", style: TextStyle(color: Colors.white70, fontSize: 16)),
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
                          hintText: "Your Name...",
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
                        child: const Text("Let's Go! 🚀", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
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

// ==========================================
// 🚀 SCREEN 3: FEATURE SHOWCASE (Colorful & Custom Images!)
// ==========================================
class FeatureShowcaseScreen extends StatefulWidget {
  const FeatureShowcaseScreen({super.key});

  @override
  State<FeatureShowcaseScreen> createState() => _FeatureShowcaseScreenState();
}

class _FeatureShowcaseScreenState extends State<FeatureShowcaseScreen> {
  // Animation Triggers
  bool _showCard1 = false;
  bool _showCard2 = false;
  bool _showCard3 = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if(mounted) setState(() => _showCard1 = true);
    
    await Future.delayed(const Duration(milliseconds: 300));
    if(mounted) setState(() => _showCard2 = true);

    await Future.delayed(const Duration(milliseconds: 300));
    if(mounted) setState(() => _showCard3 = true);

    await Future.delayed(const Duration(milliseconds: 300));
    if(mounted) setState(() => _showButton = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Look what you can do!", 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0288D1)),
              ),
              const SizedBox(height: 8),
              const Text(
                "You have 3 super tools:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 25),
              
              // 1. AI SCANNER (Purple/Pink Gradient)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showCard1 ? 1.0 : 0.0,
                curve: Curves.easeOut,
                child: Transform.translate(
                  offset: _showCard1 ? Offset.zero : const Offset(0, 20),
                  child: _buildGradientCard(
                    imagePath: 'assets/tooth_scan.png', // <--- YOUR CUSTOM IMAGE
                    title: "AI Tooth Scanner", 
                    subtitle: "Finds cavities, stains & plaque!", 
                    gradient: const LinearGradient(colors: [Color(0xFFBA68C8), Color(0xFFE91E63)]), 
                  ),
                ),
              ),
              const SizedBox(height: 15),
              
              // 2. AR MODELS (Teal/Blue Gradient)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showCard2 ? 1.0 : 0.0,
                curve: Curves.easeOut,
                 child: Transform.translate(
                  offset: _showCard2 ? Offset.zero : const Offset(0, 20),
                  child: _buildGradientCard(
                    imagePath: 'assets/tooth_AR.png', // <--- YOUR CUSTOM IMAGE
                    title: "3D Magic Models", 
                    subtitle: "See inside a tooth with magic!", 
                    gradient: const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF009688)]), 
                  ),
                ),
              ),
              const SizedBox(height: 15),
              
              // 3. SMART E-LEARNING (Orange/Yellow Gradient)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showCard3 ? 1.0 : 0.0,
                curve: Curves.easeOut,
                 child: Transform.translate(
                  offset: _showCard3 ? Offset.zero : const Offset(0, 20),
                  child: _buildGradientCard(
                    imagePath: 'assets/tooth_edu.png', // <--- YOUR CUSTOM IMAGE
                    title: "Smart E-Learning",  
                    subtitle: "Includes Games, Quiz & Timer!", 
                    gradient: const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFFF9800)]), 
                  ),
                ),
              ),
              
              const Spacer(),
              
              // BUTTON (Animated)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showButton ? 1.0 : 0.0,
                child: SizedBox(
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {
                      SoundManager.playPop(); 
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0288D1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: Colors.blueAccent.withOpacity(0.5),
                    ),
                    child: const Text("Start My Adventure! ⭐", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 UPDATED HELPER: Bigger Images (Height 55)
  Widget _buildGradientCard({
    required String imagePath, 
    required String title, 
    required String subtitle, 
    required Gradient gradient
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          // White circle background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
            
            // --- BIGGER IMAGE ---
            child: Image.asset(
              imagePath, 
              height: 55, // <--- Big Size
              width: 55,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.2, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }
}