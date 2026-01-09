// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'package:easy_localization/easy_localization.dart';
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
        title: Text('startNewAdventure'.tr(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.warning_amber_rounded, size: 60, color: AppColors.accentOrange),
            const SizedBox(height: 15),
            Text('resetWarning'.tr(), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('areYouSure'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _playPop(); 
              Navigator.pop(context, false);
            }, 
            child: Text('cancel'.tr(), style: const TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed, shape: const StadiumBorder()),
            onPressed: () {
              _playPop(); 
              Navigator.pop(context, true);
            }, 
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Text('yesReset'.tr(), style: const TextStyle(color: Colors.white))),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text('heroGuide'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
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
              _buildSectionHeader('howToPlay'.tr(), Icons.gamepad_rounded, AppColors.successGreen),
              const SizedBox(height: 10),
              _ManualSection(
                children: [
                  _ManualEntry(
                    header: '${'fire'.tr()} ${'howDoIGetAStreak'.tr()}',
                    content: 'streakExplanation'.tr(),
                  ),
                  _ManualEntry(
                    header: '${'upArrow'.tr()} ${'howDoILevelUp'.tr()}',
                    content: 'levelUpExplanation'.tr(),
                  ),
                  _ManualEntry(
                    header: '${'trophy'.tr()} ${'howToUnlockTrophies'.tr()}',
                    content: 'trophiesExplanation'.tr(),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- SECTION 2: COOL FEATURES (Updated!) ---
              _buildSectionHeader('coolFeatures'.tr(), Icons.star_rounded, Colors.amber),
              const SizedBox(height: 10),
              _ManualSection(
                children: [
                  // 🔥 NEW: E-Learning Info
                  _ManualEntry(
                    header: '${'books'.tr()} ${'toothSchoolAndQuiz'.tr()}',
                    content: 'toothSchoolExplanation'.tr(),
                  ),
                  _ManualEntry(
                    header: '${'camera'.tr()} ${'magicAiScanner'.tr()}',
                    content: 'aiScannerExplanation'.tr(),
                  ),
                  _ManualEntry(
                    header: '${'sparkles'.tr()} ${'threeDMagicCamera'.tr()}',
                    content: 'threeDCameraExplanation'.tr(),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- SECTION 3: HELP ---
              _buildSectionHeader('fixingGlitches'.tr(), Icons.build_rounded, Colors.grey),
              const SizedBox(height: 10),
              _ManualSection(
                children: [
                  _ManualEntry(
                    header: 'appIsSlow'.tr(),
                    content: 'appSlowExplanation'.tr(),
                  ),
                  _ManualEntry(
                    header: 'soundNotWorking'.tr(),
                    content: 'soundExplanation'.tr(),
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
                    Text("${'dangerZone'.tr()} ⚠️", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                    const SizedBox(height: 5),
                    Text('wantToStartOver'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
                        label: Text('resetMyAdventure'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
          Text('needHelp'.tr(), style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          SelectableText('nnabila.salim@gmail.com', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDarkBlue.withOpacity(0.8))),
        ],
      ),
    );
  }
}