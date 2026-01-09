// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // Add this
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/sound_manager.dart';
import 'about_screen.dart';
import 'user_manual_screen.dart';
import 'elearning_screen.dart';
import 'ai_scan_screen.dart';
import 'chat_screen.dart';
import 'tooth_ar_screen.dart'; // Ensure this is imported

// --- APP THEME COLORS ---
class AppColors {
  static const Color primaryBlue = Color(0xFF4FC3F7);
  static const Color primaryDarkBlue = Color(0xFF0288D1);
  static const Color background = Color(0xFFE1F5FE);
  static const Color darkText = Color(0xFF01579B);
  static const Color accentOrange = Color(0xFFFF9800);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  
  // Create a Key to trigger HomeContent refresh
  final GlobalKey<_HomeContentState> _homeKey = GlobalKey();
  late AnimationController _fabPulseController;
  late Animation<double> _fabScaleAnimation;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(key: _homeKey), 
      const ElearningScreen(),
      const AboutScreen(),
      const UserManualScreen(), // This is fine because UserManualScreen uses Consumer internally
    ];

    // 💓 Pulse Animation for the AI Scanner Button
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _fabPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // --- SUPER SCANNER BUTTON (AI SCANNER) ---
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: Container(
          height: 75, width: 75,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9800)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4))],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: FloatingActionButton(
            onPressed: () {
              SoundManager.playPop();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ToothScanScreen()));
            },
            backgroundColor: Colors.transparent, elevation: 0, shape: const CircleBorder(),
            child: const Icon(Icons.center_focus_weak_rounded, color: Colors.white, size: 40),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), notchMargin: 10.0, color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(Icons.home_rounded, 'home'.tr(), 0),
            _buildNavBarItem(Icons.school_rounded, 'learn'.tr(), 1),
            const SizedBox(width: 48),
            _buildNavBarItem(Icons.info_rounded, 'about'.tr(), 2),
            _buildNavBarItem(Icons.menu_book_rounded, 'guide'.tr(), 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        SoundManager.playPop();
        
        setState(() => _selectedIndex = index);
        
        // Refresh Home Data when clicking Home Tab
        if (index == 0) {
          _homeKey.currentState?._loadData();
        }
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: isSelected ? AppColors.primaryDarkBlue : Colors.grey[400], size: 30),
        Text(label, style: TextStyle(color: isSelected ? AppColors.primaryDarkBlue : Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// --- MAIN HOME CONTENT ---
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _hintController;
  late Animation<double> _fadeAnimation;

  // Stats
  String _userName = "Hero";
  bool _morningBrush = false;
  bool _nightBrush = false;
  int _xp = 0;
  int _streak = 0;
  int _lessonsCompleted = 0;

  //  Mixed List for Shuffling (Videos, Myths, Facts)
  final List<Lesson> _discoveryLessons = [
    Lesson(
      id: "5",
      category: "Video",
      title: "The 2-Minute Groove! 💃",
      subtitle: "Watch: Brushing like a champion",
      image: "assets/elearning/brushteeth.png",
      videoUrl: "https://youtu.be/CmZp1wdJAw4?si=Q57U1KdjedGkdN0j",
      content: "Ready to dance with your toothbrush? 🪥✨\n\n**Learn the 3 Magic Moves:**\n1. **Small Circles:** Move your brush like a tiny Ferris wheel 🎡.\n2. **The 45-Degree Tilt:** Aim at the gum line where germs hide!\n3. **The Tongue Tickle:** Brush your tongue for super fresh breath! 👅\n\n📺 **Tap Play to start your training!**",
    ),
    Lesson(
      id: "9",
      category: "Video",
      title: "The Flossing Thread Trick 🧵",
      subtitle: "Watch: Cleaning between the 'Hero Team'",
      image: "assets/elearning/floss.png",
      videoUrl: "https://youtu.be/VsgSLYWx5-0?si=btSSC-xrNk_vKvAw",
      content: "Toothbrushes can't reach everywhere! That's where **Floss** comes in. 🕵️‍♂️\n\n**What to watch for:**\n• **The 'C' Shape:** Wrap the floss around the tooth like a hug 🤗.\n• **Up and Down:** Gently slide it under the gum line.\n• **Fresh Spot:** Use a clean piece of thread for every tooth!\n\n📺 **Watch carefully and try it tonight!**",
    ),
    Lesson(
      id: "3",
      category: "Myth",
      title: "The Sugar Monster Myth 👹",
      subtitle: "Myth vs. Fact: Is candy the only villain?",
      image: "assets/elearning/candy.png",
      videoUrl: "",
      content: "Is candy the only thing that causes cavities? Let's find out! 🕵️‍♂️\n\n❌ **The Myth:** \"If I don't eat candy, I won't get cavities!\"\n✅ **The Fact:** Sticky foods like **crackers, bread, and dried fruit** can stay on your teeth longer than chocolate! 🥨 Bacteria turn these starches into acid just like sugar.\n\n🎯 **Mini Challenge:** Can you name one healthy snack that isn't sticky? 🍎",
    ),
    Lesson(
      id: "1",
      category: "Core",
      title: "Meet Your Teeth!",
      subtitle: "Discover your smile heroes 😁",
      image: "assets/elearning/teeth_type.jpg",
      videoUrl: "",
      content: "🦷 Hey Tooth Hero! Did you know your **teeth** are like a superhero team inside your mouth?\n\nLet’s meet them 👇\n\n• **Incisors** – Front teeth that **cut food** like scissors ✂️\n• **Canines** – The Tigers! 🐯 Sharp teeth that **tear food** like a tiger 🐯\n• **Premolars** – The Crushers! 🍪 Strong teeth that **crush snacks**\n• **Molars** – Big back teeth that **grind food** into tiny pieces 🥦\n\nInside every tooth, there are 3 important parts:\n• **Enamel** – The hard outer shield 🛡️\n• **Dentin** – The strong layer under enamel\n• **Pulp** – The soft center where nerves live ⚡\n\n💡 **Why this matters:** Healthy teeth help you eat, talk, and smile with confidence!\n🎯 **Mini Challenge:** Can you count how many teeth you have today? 😄\n🤖 *AI link:* AI checks these teeth to see if they are healthy or not.",
    ),
  ];

  late Lesson _featuredLesson = _discoveryLessons[Random().nextInt(_discoveryLessons.length)];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _hintController = AnimationController(duration: const Duration(seconds: 1), vsync: this)..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_hintController);
    _checkNewDayAndLoad(); 
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _hintController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- LOGIC: DAILY RESET & STREAK CHECK ---
  Future<void> _checkNewDayAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    
    String todayStr = DateTime.now().toIso8601String().split('T')[0];
    DateTime today = DateTime.parse(todayStr);
    
    String? lastBrushStr = prefs.getString('last_brush_date');
    String? lastOpenStr = prefs.getString('last_open_date');

    // Daily Reset
    if (lastOpenStr != todayStr) {
      await prefs.setBool('morning_brush', false);
      await prefs.setBool('night_brush', false);
      await prefs.setString('last_open_date', todayStr);
    }

    // Streak Reset Check (>1 day gap)
    if (lastBrushStr != null) {
      DateTime lastBrush = DateTime.parse(lastBrushStr);
      int daysDifference = today.difference(lastBrush).inDays;
      if (daysDifference > 1) {
        await prefs.setInt('streak_count', 0);
      }
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // 🛡️ Safety Check
    setState(() {
      _userName = prefs.getString('user_name') ?? "Hero";
      _morningBrush = prefs.getBool('morning_brush') ?? false;
      _nightBrush = prefs.getBool('night_brush') ?? false;
      _xp = prefs.getInt('user_xp') ?? 0;
      _streak = prefs.getInt('streak_count') ?? 0;
      List<String> finishedLessons = prefs.getStringList('completed_lessons') ?? [];
      _lessonsCompleted = finishedLessons.length;
    });
  }

  // --- LOGIC: RANKS & LEVELS ---
  int get _level => (_xp / 100).floor() + 1;
  double get _levelProgress => (_xp % 100) / 100;
  int get _xpToNextLevel => 100 - (_xp % 100);
  
  // 🔥 FIXED: Helper to find the START of the current rank
  int _getStartRankLevel(int level) {
    if (level >= 50) return 50; 
    if (level >= 30) return 30;
    if (level >= 20) return 20;
    if (level >= 10) return 10;
    if (level >= 5)  return 5;
    return 1; // Default start for Cadet
  }

  String _getNextRankName(int level) {
    if (level >= 50) return "MAX RANK";
    if (level >= 30) return "Legendary Hero"; 
    if (level >= 20) return "Tooth Master"; 
    if (level >= 10) return "Smile Guardian"; 
    if (level >= 5)  return "Cavity Fighter"; 
    return "Plaque Protector"; 
  }

  int _getNextRankLevel(int level) {
    if (level >= 50) return 100; 
    if (level >= 30) return 50;
    if (level >= 20) return 30;
    if (level >= 10) return 20;
    if (level >= 5)  return 10;
    return 5; 
  }
  
  String _getRankName(int level) {
    if (level >= 50) return "Legendary Hero 🦸‍♂️";
    if (level >= 30) return "Tooth Master 👑";
    if (level >= 20) return "Smile Guardian 🌟";
    if (level >= 10) return "Cavity Fighter ⚔️";
    if (level >= 5)  return "Plaque Protector 🛡️";
    return "Tooth Cadet 🦷"; 
  }

  void _playSound(String path) async { try { await _audioPlayer.play(AssetSource(path)); } catch (e) {} }

  Future<void> _completeMission(String key) async {
    final prefs = await SharedPreferences.getInstance();
    int oldLevel = _level;
    await prefs.setBool(key, true);
    int currentXp = prefs.getInt('user_xp') ?? 0;
    await prefs.setInt('user_xp', currentXp + 20);
    
    // 🔥 UPDATED: Only increment streak if BOTH missions are done
    bool m = prefs.getBool('morning_brush') ?? false;
    bool n = prefs.getBool('night_brush') ?? false;

    if (m && n) {
      String today = DateTime.now().toIso8601String().split('T')[0];
      String? lastDate = prefs.getString('last_brush_date');
      if (lastDate != today) {
        int streak = prefs.getInt('streak_count') ?? 0;
        await prefs.setInt('streak_count', streak + 1);
        await prefs.setString('last_brush_date', today);
      }
    }
    
    await _loadData();
    
    if (!mounted) return; // 🛡️ Safety Check
    SoundManager.playPop(); 
    
    if (_morningBrush && _nightBrush) {
       _confettiController.play(); 
       await Future.delayed(const Duration(milliseconds: 500));
       if (!mounted) return; // 🛡️ Safety Check
      _playSound('audio/yahoo.mp3');
    }
    
    if (_level > oldLevel) _showLevelUpDialog(_level);
  }

  // --- POPUPS & SNACKBARS ---
  
  void _showFloatingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.all(20),   
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: AppColors.accentOrange,
        duration: const Duration(seconds: 2),
      )
    );
  }

  void _showXPInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('yourHeroRank'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.primaryDarkBlue, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.shield_rounded, size: 60, color: AppColors.primaryBlue),
          const SizedBox(height: 15),
          Text('currentLevel'.tr(namedArgs: {'level': '$_level'}), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('rankColon'.tr(namedArgs: {'rank': _getRankName(_level)}), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const Divider(height: 30),
          Text("⬇️ ${'howToUpgrade'.tr()} ⬇️", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
          const SizedBox(height: 10),
          Text('needXPForNextLevel'.tr(namedArgs: {'xp': '$_xpToNextLevel', 'level': '${_level + 1}'}), textAlign: TextAlign.center),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Text('tickChecklist'.tr(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('awesome'.tr()))],
      ),
    );
  }

  void _showStreakInfo() {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('keepFire'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
      content: Text('completeDailyMissions'.tr(), textAlign: TextAlign.center),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('gotIt'.tr()))],
    ));
  }
  
  void _showBadgeMission(String t, String instructions, bool u) {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(u ? 'youWon'.tr() : 'howToUnlock'.tr(), textAlign: TextAlign.center, style: TextStyle(color: u ? Colors.green : Colors.grey)), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(u ? Icons.check_circle : Icons.lock, size: 50, color: u ? Colors.green : Colors.grey),
        const SizedBox(height: 15),
        Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), 
        const SizedBox(height: 10),
        Text(u ? 'missionComplete'.tr() : instructions, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('okay'.tr()))],
    ));
  }

  void _showLevelUpDialog(int level) {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text('levelUp'.tr(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        content: Text('yahoo'.tr(namedArgs: {'name': _userName, 'level': '$level'})),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('yay'.tr()))],
      ));
  }

  // ✏️ NEW: Edit Name Dialog
  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('whatIsYourName'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          autofocus: true, // ⚡ UX: Open keyboard immediately
          decoration: InputDecoration(hintText: 'enterYourName'.tr()),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', nameController.text.trim().isEmpty ? "Hero" : nameController.text.trim());
              if (mounted) Navigator.pop(context);
              _loadData();
            },
            child: Text('save'.tr()),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Removed Consumer<LocalizationService> wrapper
        String rankName = _getRankName(_level);
        String nextRankName = _getNextRankName(_level);
        int nextRankLvl = _getNextRankLevel(_level);

        // 🔥 FIXED: Get the start level so progress bar is accurate
        int startRankLvl = _getStartRankLevel(_level);

        // ✨ UI ENHANCEMENT: Use Stack for seamless background layering
        return Stack(
          children: [
            // 1. FIXED BACKGROUND GRADIENT (Solves the "Dark Corner" issue)
            Container(
              height: 400, // Covers the top part of the screen
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.primaryDarkBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // 2. SCROLLABLE CONTENT
            SingleChildScrollView(
              child: Column(
                children: [
                  // HEADER (Transparent, sits on top of gradient)
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40), // More breathing room
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center, // Align center vertically
                        children: [
                          // LEFT SIDE: Greeting
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _showEditNameDialog, // ✏️ Tap to edit name
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text('${'hi'.tr()}, $_userName!', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]), overflow: TextOverflow.ellipsis),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('letsHuntSugarBugs'.tr(), style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),

                          // RIGHT SIDE: Compact Actions (Horizontal)
                          Row(
                            children: [
                              // 🔥 THE CHAT BUTTON
                              GestureDetector(
                                onTap: () {
                                  SoundManager.playPop();
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.3))
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text('aiChat'.tr(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Image.asset('assets/tooth_logo.png', height: 50), // Logo
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // WHITE CONTENT AREA
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(35)), // Smoother roundness
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))] // Depth
                    ),
                    padding: const EdgeInsets.fromLTRB(25, 35, 25, 100), // More top padding inside sheet
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HERO CARD
                        _buildHeroCard(rankName, nextRankName, _levelProgress, _level, startRankLvl, nextRankLvl),
                        const SizedBox(height: 25),

                        // MISSION BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${'myMissions'.tr()} 📝', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                            FadeTransition(opacity: _fadeAnimation, child: Text("${'tickEveryday'.tr()} 👇", style: const TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                          _buildMissionToggle("${'morning'.tr()}\n${'brush'.tr()}", Icons.wb_sunny_rounded, _morningBrush, 'morning_brush', const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFFF9800)]), Colors.orange),
                          const SizedBox(width: 15),
                          _buildMissionToggle("${'night'.tr()}\n${'brush'.tr()}", Icons.bedtime_rounded, _nightBrush, 'night_brush', const LinearGradient(colors: [Color(0xFF9FA8DA), Color(0xFF3F51B5)]), Colors.indigo),
                        ]),

                        const SizedBox(height: 25),
                        Text('${'threeDMagicCamera'.tr()} ✨', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                        const SizedBox(height: 12),
                        _buildARCard(),

                        const SizedBox(height: 25),
                        Text('${'myTrophies'.tr()} 🏆', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                        const SizedBox(height: 12),
                        _buildTrophyRow(),

                        const SizedBox(height: 25),
                        Text('${'dailyDiscovery'.tr()} 💡', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                        const SizedBox(height: 12),
                        _buildDiscoveryCard(),

                        const SizedBox(height: 40),
                        // 🏥 CLIENT BRANDING FOOTER
                        Center(
                          child: Text(
                            'madeWithLove'.tr(),
                            style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. CONFETTI (Top Layer)
            Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false, colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange])),
          ],
        );
  }

  // --- WIDGETS ---
  
  // 🔥 UPDATED: Added new parameters (startRankLvl)
  Widget _buildHeroCard(String rank, String nextRank, double progress, int currentLvl, int startRankLvl, int nextRankLvl) {
    
    // 🔥 FIXED: Calculate relative progress.
    // If you are Level 1 (Start 1, Next 5): (1-1) / (5-1) = 0.0 (Empty Bar)
    double rankProgress = 0.0;
    if (nextRankLvl > startRankLvl) {
      rankProgress = (currentLvl - startRankLvl) / (nextRankLvl - startRankLvl);
    }
    // Clamp to ensure safety
    rankProgress = rankProgress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(children: [
        GestureDetector(
          onTap: () { SoundManager.playPop(); _showXPInfo(); }, 
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 70, height: 70, child: CircularProgressIndicator(value: progress, backgroundColor: Colors.grey[200], color: AppColors.accentOrange, strokeWidth: 8)),
            const Icon(Icons.shield_rounded, color: AppColors.primaryBlue, size: 35),
          ]),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rank, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.darkText)),
          Text(_userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 5),
          Text("${'next'.tr()}: $nextRank (Lvl $nextRankLvl)", style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          
          // 🔥 FIXED: Use the new rankProgress here
          ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: rankProgress, backgroundColor: Colors.grey[200], color: AppColors.primaryBlue, minHeight: 6)),
          
          const SizedBox(height: 8),
          
          GestureDetector(
            onTap: () { SoundManager.playPop(); _showXPInfo(); },
            child: Text('tapToSeeYourRank'.tr(), style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
          ),
          
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () { SoundManager.playPop(); _showStreakInfo(); },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 16), const SizedBox(width: 5), Text('dayStreak'.tr(namedArgs: {'count': '$_streak'}), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12))])),
          ),
        ])),
      ]),
    );
  }

  Widget _buildMissionToggle(String title, IconData icon, bool done, String key, Gradient activeGradient, Color iconColor) {
    return Expanded(
      child: GestureDetector(
        onTap: done
          ? () { SoundManager.playPop(); _showFloatingSnackBar("${'goodJob'.tr()}! ${'alreadyDidThisToday'.tr()} 👍"); }
          : () => _completeMission(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(gradient: done ? activeGradient : null, color: done ? null : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: done ? Colors.transparent : iconColor.withOpacity(0.5), width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Column(children: [
            Icon(icon, color: done ? Colors.white : iconColor, size: 35),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: done ? Colors.white : Colors.grey)),
            const SizedBox(height: 5),
            Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: done ? Colors.white : Colors.grey[200], size: 28),
          ]),
        ),
      ),
    );
  }

  Widget _buildTrophyRow() {
    return SizedBox(height: 110, child: ListView(scrollDirection: Axis.horizontal, children: [
      _buildBadge("Early Bird", Icons.wb_sunny_rounded, _morningBrush, Colors.orange, 'brushTeethMorning'.tr()),
      _buildBadge("Night Owl", Icons.bedtime_rounded, _nightBrush, Colors.indigo, 'brushTeethNight'.tr()),
      _buildBadge("Plaque Protector", Icons.verified_rounded, _level >= 5, Colors.red, 'reachLevel5'.tr()),
      _buildBadge("Tooth Genius", Icons.school_rounded, _lessonsCompleted >= 13, Colors.green, 'finishAllLessons'.tr(), "$_lessonsCompleted/13"),
    ]));
  }

  Widget _buildBadge(String n, IconData i, bool u, Color c, String instructions, [String? p]) {
    return GestureDetector(
      onTap: () { SoundManager.playPop(); _showBadgeMission(n, instructions, u); },
      child: Container(
        width: 100, margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: u ? c.withOpacity(0.1) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20), border: u ? Border.all(color: c, width: 2) : null),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, color: u ? c : Colors.grey[300], size: 32), 
          const SizedBox(height: 5),
          Text(n, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: u ? c : Colors.grey)),
          if (p != null && !u) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(p, style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.bold)))
        ]),
      ),
    );
  }

  // 🔥 UPDATED AR CARD: Links to ToothARScreen
  Widget _buildARCard() {
    return InkWell(
      onTap: () { SoundManager.playPop(); Navigator.push(context, MaterialPageRoute(builder: (_) => const ToothARScreen())); },
      child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF26C6DA)]), borderRadius: BorderRadius.circular(25)), child: Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("See Magic Teeth!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text("Use AR to see inside a tooth", style: TextStyle(color: Colors.white, fontSize: 12))])),
        Image.asset('assets/tooth_AR.png', height: 60, errorBuilder: (c,e,s) => const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 50)),
      ])),
    );
  }
  
  Widget _buildDiscoveryCard() {
    String category = _featuredLesson.category;
    bool isVideo = category == "Video";
    bool isMyth = category == "Myth";
    
    // 🎨 Dynamic Colors based on Category (Matches Learning Screen)
    List<Color> gradientColors;
    IconData icon;
    Color shadowColor;

    if (isVideo) {
      gradientColors = [const Color(0xFFEC407A), const Color(0xFFAB47BC)]; // Pink/Purple
      icon = Icons.play_circle_fill_rounded;
      shadowColor = Colors.pink;
    } else if (isMyth) {
      gradientColors = [const Color(0xFF8E44AD), const Color(0xFFF962A9)]; // Purple/Pink
      icon = Icons.help_outline_rounded;
      shadowColor = Colors.purple;
    } else {
      gradientColors = [const Color(0xFF43A047), const Color(0xFF66BB6A)]; // Green
      icon = Icons.lightbulb_circle_rounded;
      shadowColor = Colors.green;
    }
    
    return InkWell(
      onTap: () {
        SoundManager.playPop();
        // Navigate directly to the specific Lesson
        Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(lesson: _featuredLesson)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(children: [Icon(icon, color: Colors.white, size: 40), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_featuredLesson.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Text(_featuredLesson.subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70))]))]),
      ),
    );
  }
}