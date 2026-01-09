// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// --- THEME COLORS (Synced with Home Screen) ---
class AppColors {
  static const Color primaryBlue = Color(0xFF4FC3F7);
  static const Color primaryDarkBlue = Color(0xFF0288D1);
  static const Color background = Color(0xFFE1F5FE);
  static const Color darkText = Color(0xFF01579B);
  static const Color cardBg = Colors.white;
}

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Setup Fade Animation
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        automaticallyImplyLeading: false, // Removed Back Button (It's a main tab)
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'about'.tr(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // --- 1. BRANDING HEADER ---
              const SizedBox(height: 10),
              Image.asset('assets/tooth_logo.png', height: 100), // <--- Added Logo
              const SizedBox(height: 15),
              Text(
                'appName'.tr(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.darkText),
              ),
              Text(
                'healthySmilesForEveryone'.tr(),
                style: const TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 30),

              // --- 2. WHAT WE DO ---
              _InfoCard(
                title: 'ourMission'.tr(),
                content: 'ourMissionContent'.tr(),
                icon: Icons.favorite_rounded,
                iconColor: Colors.pinkAccent,
              ),

              // --- 3. TECH STACK ---
              _InfoCard(
                title: 'techMagic'.tr(),
                content: 'techMagicContent'.tr(),
                icon: Icons.code_rounded,
                iconColor: Colors.purpleAccent,
              ),

              // --- 4. TEAM CARD ---
              const _TeamCard(),

              // --- 5. VERSION ---
              const _VersionInfo(),
              const SizedBox(height: 50), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------

// --- Helper Widget for Info Cards ---
class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;

  const _InfoCard({required this.title, required this.content, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),
              Text(
                content,
                style: TextStyle(fontSize: 14, color: AppColors.darkText.withOpacity(0.8), height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Helper Widget for Team ---
class _TeamCard extends StatelessWidget {
  const _TeamCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.groups_rounded, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'developmentTeam'.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),

              _TeamDetail(role: 'developer'.tr(), name: 'NUR NABILA SHAHIRAH BINTI SALIM', icon: Icons.person_rounded),
              const SizedBox(height: 10),
              _TeamDetail(role: 'supervisor'.tr(), name: 'TS. DR. NURUL AMELINA BINTI NASHARUDDIN', icon: Icons.school_rounded),
              const SizedBox(height: 10),
              _TeamDetail(role: 'partner'.tr(), name: 'clinicName'.tr(), icon: Icons.local_hospital_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamDetail extends StatelessWidget {
  final String role;
  final String name;
  final IconData icon;

  const _TeamDetail({required this.role, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Helper Widget for Version Info ---
class _VersionInfo extends StatelessWidget {
  const _VersionInfo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.verified_user_rounded, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text('${'version'.tr()} 1.0.1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 5),
          Text('copyright'.tr(), style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}