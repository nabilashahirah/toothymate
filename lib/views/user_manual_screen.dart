// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'welcome_screens.dart'; 

// --- THEME COLORS ---
class AppColors {
  static const Color primaryBlue = Color(0xFF4FC3F7);
  static const Color primaryDarkBlue = Color(0xFF0288D1);
  static const Color background = Color(0xFFE1F5FE);
  static const Color darkText = Color(0xFF01579B);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color dangerRed = Color(0xFFFF5252);
  static const Color successGreen = Color(0xFF4CAF50);
}

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- HELPER: PLAY SOUND ---
  void _playPop() async {
    try { await _audioPlayer.play(AssetSource('audio/pop.mp3')); } catch (e) {}
  }

  // --- RESET LOGIC ---
  Future<void> _resetAdventure(BuildContext context) async {
    _playPop(); 

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Start New Adventure?", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 60, color: AppColors.accentOrange),
            SizedBox(height: 15),
            Text("This will delete your Name, Level, and Trophies forever!", textAlign: TextAlign.center),
            SizedBox(height: 10),
            Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _playPop(); 
              Navigator.pop(context, false);
            }, 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed, shape: const StadiumBorder()),
            onPressed: () {
              _playPop(); 
              Navigator.pop(context, true);
            }, 
            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Yes, Reset!", style: TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false, 
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.primaryDarkBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Hero Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              // --- SECTION 1: HOW TO PLAY ---
              _buildSectionHeader("How to Play", Icons.gamepad_rounded, AppColors.successGreen),
              const SizedBox(height: 10),
              const _ManualSection(
                children: [
                  _ManualEntry(
                    header: '🔥 How do I get a Streak?',
                    content: 'A Streak is when you brush everyday without stopping! Tap the checkboxes on the Home screen daily. If you miss one day, your fire goes out!',
                  ),
                  _ManualEntry(
                    header: '🆙 How do I Level Up?',
                    content: 'You need XP (Experience Points) to level up. Every time you tick a mission, you get +20 XP. Reach 100 XP to grow from a Cadet to a Legend!',
                  ),
                  _ManualEntry(
                    header: '🏆 How to unlock Trophies?',
                    content: 'Tap on any gray trophy to see the secret mission. Some require brushing early, and some require finishing lessons in Tooth School.',
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- SECTION 2: COOL FEATURES (Updated!) ---
              _buildSectionHeader("Cool Features", Icons.star_rounded, Colors.amber),
              const SizedBox(height: 10),
              const _ManualSection(
                children: [
                  // 🔥 NEW: E-Learning Info
                  _ManualEntry(
                    header: '📚 Tooth School & Quiz',
                    content: 'Go to the "Learn" tab to watch videos! Test your brain with Quizzes and use the Timer to brush perfectly for 2 minutes.',
                  ),
                  _ManualEntry(
                    header: '📸 Magic AI Scanner',
                    content: 'Tap the big Orange Button at the bottom! Point the camera at your teeth to detect plaque or cavities using AI.',
                  ),
                  _ManualEntry(
                    header: '✨ 3D Magic Camera',
                    content: 'Tap the blue card on the Home screen to see a magical 3D tooth floating in your room!',
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- SECTION 3: HELP ---
              _buildSectionHeader("Fixing Glitches", Icons.build_rounded, Colors.grey),
              const SizedBox(height: 10),
              const _ManualSection(
                children: [
                  _ManualEntry(
                    header: 'App is slow?',
                    content: 'Try closing other apps on your phone. ToothyMate needs energy to run the AI Scanner!',
                  ),
                  _ManualEntry(
                    header: 'Sound not working?',
                    content: 'Check your phone volume. We want you to hear the "Yahoo!" when you win.',
                  ),
                ],
              ),
              
              const SizedBox(height: 35),

              // --- SECTION 4: RESET ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dangerRed.withOpacity(0.3), width: 2),
                  boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const Text("Danger Zone ⚠️", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                    const SizedBox(height: 5),
                    const Text("Want to start over with a new name?", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dangerRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        onPressed: () => _resetAdventure(context),
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        label: const Text("Reset My Adventure", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              const _ContactInfo(),
              const SizedBox(height: 50), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 15),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.darkText)),
      ],
    );
  }
}

// --- HELPER WIDGETS ---

class _ManualSection extends StatelessWidget {
  final List<Widget> children;
  const _ManualSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }
}

class _ManualEntry extends StatelessWidget {
  final String header;
  final String content;

  const _ManualEntry({required this.header, required this.content});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
        title: Text(header, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText, fontSize: 15)),
        iconColor: AppColors.accentOrange,
        collapsedIconColor: Colors.grey[400],
        childrenPadding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(content, style: TextStyle(color: AppColors.darkText.withOpacity(0.8), fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  const _ContactInfo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('Need help?', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          SelectableText('nnabila.salim@gmail.com', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDarkBlue.withOpacity(0.8))),
        ],
      ),
    );
  }
}