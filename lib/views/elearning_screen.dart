import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// --- App Colors & Styles ---
class AppColors {
  static const Color primaryBlue = Color(0xFF33D4FF);
  static const Color primaryDarkBlue = Color(0xFF0F82EB);
  static const Color background = Color(0xFFF0F4F8);

  static const List<Color> coreGradient = [Color(0xFF27AE60), Color(0xFF2ECC71)];
  static const List<Color> mythGradient = [Color(0xFF8E44AD), Color(0xFFF962A9)];
  static const List<Color> momGradient = [Color(0xFFFF758C), Color(0xFFFF9A9E)];
  static const List<Color> videoGradient = [Color(0xFF3498DB), Color(0xFF4DB6AC)];
}

// --- Lesson Model ---
class Lesson {
  final String id, category, title, subtitle, content, image, videoUrl;
  late final TextSpan parsedContent;

  Lesson({
    required this.id, required this.category, required this.title, 
    required this.subtitle, required this.content, required this.image,
    required this.videoUrl,
  }) {
    parsedContent = parseText(content);
  }

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] ?? '0',
    category: json['category'] ?? 'Core',
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    content: json['content'] ?? '',
    image: json['image'] ?? '',
    videoUrl: json['videoUrl'] ?? '',
  );

  static TextSpan parseText(String text) {
    List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > start) spans.add(TextSpan(text: text.substring(start, match.start)));
      spans.add(TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)));
      start = match.end;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return TextSpan(children: spans, style: const TextStyle(fontSize: 17, height: 1.6, color: Colors.black87));
  }
}

// --- MAIN HUB ---
class ElearningScreen extends StatefulWidget {
  final String? initialSearch; // Received from AI Scanner
  const ElearningScreen({super.key, this.initialSearch});

  @override
  State<ElearningScreen> createState() => _ElearningScreenState();
}

class _ElearningScreenState extends State<ElearningScreen> {
  List<Lesson> allLessons = [];
  List<Lesson> filteredLessons = [];
  List<String> completedIds = [];
  String selectedCategory = "All";
  bool loading = true;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Logic to handle auto-filtering from AI Scanner
    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
      isSearching = true; 
    }
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = await rootBundle.loadString('assets/json/lessons.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      allLessons = jsonData.map((e) => Lesson.fromJson(e)).toList();
      completedIds = prefs.getStringList('completed_lessons') ?? [];
      _applyFilter();
      loading = false;
    });
    _checkTotalCompletion();
  }

  void _applyFilter() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredLessons = allLessons.where((lesson) {
        bool matchesCategory = selectedCategory == "All" || lesson.category == selectedCategory;
        bool matchesSearch = lesson.title.toLowerCase().contains(query);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _checkTotalCompletion() {
    if (allLessons.isNotEmpty && completedIds.length == allLessons.length) {
      Future.delayed(const Duration(milliseconds: 500), () => _showHeroDiploma());
    }
  }

  void _showHeroDiploma() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎓 DENTAL MASTER GRADUATE 🎓", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 20),
              Image.asset('assets/images/mascot_grad.png', height: 150, errorBuilder: (c,e,s) => const Icon(Icons.school, size: 100, color: Colors.amber)),
              const SizedBox(height: 20),
              const Text("Amazing Work, Hero!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("You completed every mission. Your smile is officially a Super-Smile!", textAlign: TextAlign.center),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDarkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text("I'm a Pro! ⭐", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeGallery() {
    Map<String, int> stats = {
      "Core": completedIds.where((id) => allLessons.any((l) => l.id == id && l.category == "Core")).length,
      "Myth": completedIds.where((id) => allLessons.any((l) => l.id == id && l.category == "Myth")).length,
      "Mom": completedIds.where((id) => allLessons.any((l) => l.id == id && l.category == "Mom")).length,
      "Video": completedIds.where((id) => allLessons.any((l) => l.id == id && l.category == "Video")).length,
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Achievement Gallery 🏅", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true, crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1.2,
              children: stats.entries.map((e) {
                bool isDone = e.value > 0;
                return Container(
                  decoration: BoxDecoration(color: isDone ? Colors.white : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDone ? AppColors.primaryDarkBlue : Colors.transparent, width: 2)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_getIcon(e.key), color: isDone ? _getColor(e.key) : Colors.grey, size: 40),
                    const SizedBox(height: 8),
                    Text(e.key, style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? Colors.black : Colors.grey)),
                    Text("${e.value} Done", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String c) => c == "Core" ? Icons.verified_user : c == "Myth" ? Icons.bolt_rounded : c == "Mom" ? Icons.favorite : Icons.play_circle_filled;
  Color _getColor(String c) => c == "Core" ? Colors.green : c == "Myth" ? Colors.purple : c == "Mom" ? Colors.pink : Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryDarkBlue], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
        iconTheme: const IconThemeData(color: Colors.white),
        title: isSearching 
          ? TextField(controller: _searchController, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Search for a mission...", border: InputBorder.none, hintStyle: TextStyle(color: Colors.white60)), onChanged: (v) => _applyFilter())
          : const Text("Knowledge Hub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(isSearching ? Icons.close : Icons.search), onPressed: () => setState(() { isSearching = !isSearching; if(!isSearching) { _searchController.clear(); _applyFilter(); } })),
          IconButton(icon: const Icon(Icons.emoji_events_outlined), onPressed: _showBadgeGallery),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _showResetDialog),
        ],
      ),
      body: Column(children: [
        _buildFilterBar(),
        if (!loading) _buildProgressHeader(),
        Expanded(child: ClipRect(child: loading ? const Center(child: CircularProgressIndicator()) : _buildLessonList())),
      ]),
    );
  }

  void _showResetDialog() {
    showDialog(context: context, builder: (c) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text("Reset Progress?"), content: const Text("Do you want to clear your stars and badges?"), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("No")), TextButton(onPressed: () async { (await SharedPreferences.getInstance()).remove('completed_lessons'); setState(() => completedIds = []); Navigator.pop(c); _applyFilter(); }, child: const Text("Yes, Reset", style: TextStyle(color: Colors.red)))]));
  }

  Widget _buildFilterBar() {
    final cats = ["All", "Core", "Myth", "Mom", "Video"];
    return SizedBox(height: 70, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), children: cats.map((c) => Padding(padding: const EdgeInsets.only(right: 10), child: ChoiceChip(label: Text(c), selected: selectedCategory == c, onSelected: (v) { setState(() { selectedCategory = c; _applyFilter(); }); }, selectedColor: AppColors.primaryDarkBlue, backgroundColor: Colors.white, showCheckmark: false, labelStyle: TextStyle(color: selectedCategory == c ? Colors.white : AppColors.primaryDarkBlue, fontWeight: FontWeight.bold)))).toList()));
  }

  Widget _buildProgressHeader() {
    double p = allLessons.isEmpty ? 0 : completedIds.length / allLessons.length;
    return Container(margin: const EdgeInsets.fromLTRB(20, 0, 20, 15), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Row(children: [ Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: p, backgroundColor: Colors.grey.shade100, color: AppColors.primaryDarkBlue, strokeWidth: 6), Text("${(p*100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]), const SizedBox(width: 20), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Your Journey", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("${completedIds.length} lessons finished!", style: TextStyle(color: Colors.grey.shade600, fontSize: 13))])), const Icon(Icons.stars_rounded, color: Colors.amber, size: 40)]));
  }

  Widget _buildLessonList() {
    return ListView.builder(clipBehavior: Clip.none, padding: const EdgeInsets.all(20), itemCount: filteredLessons.length, itemBuilder: (context, i) {
      final l = filteredLessons[i];
      final colors = _getColors(l.category);
      final done = completedIds.contains(l.id);
      return Stack(clipBehavior: Clip.none, children: [
        Container(margin: const EdgeInsets.only(bottom: 30), height: 140, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: LinearGradient(colors: colors), boxShadow: [BoxShadow(color: colors.last.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(25), onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(lesson: l))); loadData(); }, child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [ Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15)), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: l.category == "Video" ? const Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 50) : Image.asset(l.image, fit: BoxFit.contain))), const SizedBox(width: 15), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text(l.subtitle, maxLines: 2, style: const TextStyle(color: Colors.white70, fontSize: 13))])), Icon(done ? Icons.stars_rounded : Icons.arrow_forward_ios, color: done ? Colors.amber : Colors.white)]))))),
        Positioned(top: -12, left: 15, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]), child: Text(l.category.toUpperCase(), style: TextStyle(color: colors.first, fontWeight: FontWeight.bold, fontSize: 10)))),
      ]);
    });
  }

  List<Color> _getColors(String c) => c == "Myth" ? AppColors.mythGradient : c == "Mom" ? AppColors.momGradient : c == "Video" ? AppColors.videoGradient : AppColors.coreGradient;
}

// --- LESSON DETAIL SCREEN ---
class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late ConfettiController _confetti;
  final FlutterTts tts = FlutterTts();
  final AudioPlayer sfx = AudioPlayer();
  final AudioPlayer music = AudioPlayer();
  YoutubePlayerController? yt;
  int time = 120; bool active = false; Timer? _t;
  bool isSpeaking = false;

  final Map<String, Map<String, dynamic>> lessonQuizzes = {
    "1": {"q": "Which teeth act like scissors to cut food?", "a": ["Molars", "Incisors", "Canines"], "correct": "Incisors"},
    "2": {"q": "What is the sticky layer germs build on teeth?", "a": ["Pulp", "Plaque", "Enamel"], "correct": "Plaque"},
    "3": {"q": "True or False: Candy is the only food that causes cavities.", "a": ["True", "False"], "correct": "False"},
    "4": {"q": "What brush should Mom use if her gums are sore?", "a": ["Hard Brush", "Extra Hard", "Soft Brush"], "correct": "Soft Brush"},
    "5": {"q": "How long should a champion brush their teeth?", "a": ["1 Minute", "2 Minutes", "5 Minutes"], "correct": "2 Minutes"},
    "6": {"q": "What happens when plaque turns hard as stone?", "a": ["It becomes Calculus", "It disappears", "It stays soft"], "correct": "It becomes Calculus"},
    "7": {"q": "Is brushing harder better for your teeth?", "a": ["Yes", "No, it hurts enamel"], "correct": "No, it hurts enamel"},
    "8": {"q": "Which food helps build the baby's tooth armor?", "a": ["Potato Chips", "Milk & Yogurt", "Chocolate"], "correct": "Milk & Yogurt"},
    "9": {"q": "What shape should floss make around a tooth?", "a": ["O Shape", "X Shape", "C Shape"], "correct": "C Shape"},
    "10": {"q": "Who is the only person who can remove hard Calculus?", "a": ["You", "Your Mom", "A Dentist"], "correct": "A Dentist"},
    "11": {"q": "Why are baby teeth called 'Seat Savers'?", "a": ["They save a chair", "They hold space for adult teeth"], "correct": "They hold space for adult teeth"},
    "12": {"q": "What is the 'Magic Rinse' for Mom's teeth?", "a": ["Fruit Juice", "Water & Baking Soda"], "correct": "Water & Baking Soda"},
    "13": {"q": "What is the best way to keep teeth shiny today?", "a": ["Only eating sweets", "Brushing twice a day", "Not brushing"], "correct": "Brushing twice a day"},
  };

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.lesson.videoUrl.isNotEmpty) {
      final id = YoutubePlayer.convertUrlToId(widget.lesson.videoUrl);
      if (id != null) yt = YoutubePlayerController(initialVideoId: id, flags: const YoutubePlayerFlags(autoPlay: false));
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if(mounted){
        String msg = widget.lesson.category == "Video" ? "Watch the video first, then tap play to follow along!" : "Let's learn about ${widget.lesson.title}";
        tts.speak(msg);
      }
    });
  }

  void _showQuizDialog() {
    String? err;
    if (!lessonQuizzes.containsKey(widget.lesson.id)) { _finish(); return; }
    showDialog(context: context, barrierDismissible: false, builder: (c) => StatefulBuilder(builder: (c, state) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: const Text("Knowledge Check! 🧠", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(lessonQuizzes[widget.lesson.id]!['q'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        if(err != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(err!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        const SizedBox(height: 25),
        ... (lessonQuizzes[widget.lesson.id]!['a'] as List).map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDarkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: (){ if(o == lessonQuizzes[widget.lesson.id]!['correct']) { Navigator.pop(c); _finish(); } else { HapticFeedback.vibrate(); state(() => err = "Not quite! Try again! ❌"); } }, child: Text(o, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ))
      ]),
    )));
  }

  void _finish() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> done = prefs.getStringList('completed_lessons') ?? [];
    if (!done.contains(widget.lesson.id)) { done.add(widget.lesson.id); await prefs.setStringList('completed_lessons', done); }
    _confetti.play(); sfx.play(AssetSource('audio/yahoo.mp3'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hero Progress Saved! ⭐"), backgroundColor: Colors.green));
  }

  void _toggleTimer() async {
    if(active) { _t?.cancel(); music.pause(); setState(() => active = false); }
    else {
      setState(() { active = true; if(time == 0) time = 120; });
      await music.play(AssetSource('audio/brushing_song.mp3'));
      music.setReleaseMode(ReleaseMode.loop);
      _t = Timer.periodic(const Duration(seconds: 1), (t) {
        if(time > 0) setState(() => time--);
        else { t.cancel(); music.stop(); setState(() => active = false); _showQuizDialog(); }
      });
    }
  }

  @override
  void dispose() { _t?.cancel(); _confetti.dispose(); tts.stop(); yt?.dispose(); music.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    bool isVideo = widget.lesson.category == "Video";
    bool isMyth = widget.lesson.category == "Myth";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryDarkBlue]))), title: Text(widget.lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(children: [
        SingleChildScrollView(child: Column(children: [
          if (isVideo && yt != null) YoutubePlayer(controller: yt!) else Image.asset(widget.lesson.image, height: 250, fit: BoxFit.contain),
          Padding(padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if(isVideo) _buildTimerUI(),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(widget.lesson.subtitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDarkBlue))),
              if (!isVideo) IconButton(icon: Icon(isSpeaking ? Icons.stop_circle : Icons.volume_up_rounded, color: AppColors.primaryDarkBlue, size: 35), onPressed: () {
                if (isSpeaking) { tts.stop(); setState(() => isSpeaking = false); }
                else { tts.speak(widget.lesson.content.replaceAll("**", "")); setState(() => isSpeaking = true); }
              }),
            ]),
            const SizedBox(height: 15),
            if (isMyth) _buildFlipCard() else RichText(text: widget.lesson.parsedContent),
            const SizedBox(height: 40),
            Center(child: ElevatedButton.icon(onPressed: _showQuizDialog, icon: const Icon(Icons.auto_awesome, color: Colors.white), label: const Text("I Learned This! 🌟", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDarkBlue, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))))),
            const SizedBox(height: 50),
          ])),
        ])),
        Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confetti, blastDirectionality: BlastDirectionality.explosive, colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple], createParticlePath: _drawStar)),
      ]),
    );
  }

  Widget _buildTimerUI() {
    bool isFloss = widget.lesson.title.toLowerCase().contains("floss");
    return Column(children: [
      Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber.shade300)), child: const Row(children: [Icon(Icons.lightbulb_outline, color: Colors.orange), SizedBox(width: 10), Expanded(child: Text("Watch the video first, then tap Play to follow along!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 13)))])),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(25), border: Border.all(color: AppColors.primaryBlue, width: 2)), child: Row(children: [
        Stack(alignment: Alignment.center, children: [SizedBox(width: 60, height: 60, child: CircularProgressIndicator(value: time/120, color: AppColors.primaryDarkBlue, backgroundColor: Colors.white)), Text("${time~/60}:${(time%60).toString().padLeft(2,'0')}", style: const TextStyle(fontWeight: FontWeight.bold))]),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isFloss ? "Floss Along! 🧵" : "Brush Along! 🎵", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(active ? "Doing great! ✨" : "Ready? Tap Play!")])),
        IconButton(icon: Icon(active ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 50, color: AppColors.primaryDarkBlue), onPressed: _toggleTimer),
      ])),
    ]);
  }

  Widget _buildFlipCard() {
    List<String> parts = widget.lesson.content.split("✅ **The Fact:**");
    return Column(children: [
      const Text("Tap to reveal the truth! 👇", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
      const SizedBox(height: 15),
      FlipCard(
        front: _cardFace(title: "MYTH ❌", text: parts[0].replaceAll("❌ **The Myth:**", "").trim(), color: Colors.redAccent.withOpacity(0.05), borderColor: Colors.redAccent),
        back: _cardFace(title: "FACT ✅", text: parts.length > 1 ? parts[1].trim() : "...", color: Colors.green.withOpacity(0.05), borderColor: Colors.green),
      ),
    ]);
  }

  Widget _cardFace({required String title, required String text, required Color color, required Color borderColor}) {
    return Container(width: double.infinity, constraints: const BoxConstraints(minHeight: 200), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25), border: Border.all(color: borderColor, width: 2.5)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: borderColor)), const SizedBox(height: 15), RichText(textAlign: TextAlign.center, text: Lesson.parseText(text))]));
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (math.pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < math.pi * 2; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step), halfWidth + externalRadius * math.sin(step));
      path.lineTo(halfWidth + internalRadius * math.cos(step + halfDegreesPerStep), halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}