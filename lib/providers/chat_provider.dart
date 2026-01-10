import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemini_service.dart';
import '../services/tts_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final TtsService _ttsService = TtsService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // State
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  IconData _botIcon = Icons.smart_toy_rounded;
  Color _botIconColor = Colors.white;
  bool _shouldCelebrate = false;

  // Getters
  List<Map<String, String>> get messages => _messages;
  bool get isTyping => _isTyping;
  IconData get botIcon => _botIcon;
  Color get botIconColor => _botIconColor;
  bool get shouldCelebrate => _shouldCelebrate;

  // Quick Questions Data
  final List<Map<String, dynamic>> quickQuestions = [
    {"label": "😬 Braces", "color": Colors.purpleAccent},
    {"label": "🦷 Gosok Gigi", "color": Colors.blueAccent},
    {"label": "🏥 Clinic Info", "color": Colors.teal},
    {"label": "🦠 Cavity", "color": Colors.green},
    {"label": "🤕 Sakit Gigi", "color": Colors.redAccent},
    {"label": "🍬 Candy", "color": Colors.orange},
    {"label": "😂 Joke", "color": Colors.pinkAccent},
  ];

  Future<void> init() async {
    await _geminiService.init();
    await _ttsService.init();
    await _loadChatHistory();

    if (_messages.isEmpty) {
      // Get current language from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final currentLocale = prefs.getString('app_locale') ?? 'en';

      // Set TTS language
      await _ttsService.setLanguage(currentLocale);

      final greetingText = currentLocale == 'ms'
          ? 'Hai! Saya Dr. Tooth Bot 🤖 dari Klinik Pergigian Dr. Karthi!\n\nSaya ada emosi! cuba cakap "Sakit" atau "Gula" untuk lihat muka saya berubah!'
          : 'Hello! I am Dr. Tooth Bot 🤖 from Klinik Pergigian Dr. Karthi!\n\nI have emotions! try saying "Pain" or "Candy" to see my face change!';

       _messages.add({'sender': 'bot', 'text': greetingText});
       notifyListeners();
    }

    if (_geminiService.error != null) {
      _messages.add({'sender': 'bot', 'text': "⚠️ Error: Gemini AI is not initialized. Please check your API key."});
      notifyListeners();
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedChat = prefs.getString('chat_history');
      if (savedChat != null) {
        final List<dynamic> decoded = jsonDecode(savedChat);
        _messages.clear();
        for (var item in decoded) {
          _messages.add(Map<String, String>.from(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', jsonEncode(_messages));
  }

  void resetCelebrate() {
    _shouldCelebrate = false;
    // No notifyListeners needed here to avoid loop
  }

  Future<void> handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    // 1. User Message
    _messages.add({'sender': 'user', 'text': text});
    _isTyping = true;
    _botIcon = Icons.hourglass_top_rounded;
    notifyListeners();
    _saveChatHistory();
    
    _playSound('audio/pop.mp3');
    await Future.delayed(const Duration(milliseconds: 1000));

    // 2. Update Emotion
    _updateBotEmotion(text.toLowerCase());

    // 3. Get Response (Local or AI)
    String? response = _getLocalResponse(text.toLowerCase());

    if (response == null) {
      if (_geminiService.isReady) {
        try {
          // Get current language
          final prefs = await SharedPreferences.getInstance();
          final currentLocale = prefs.getString('app_locale') ?? 'en';

          final persona = currentLocale == 'ms'
              ? "Anda adalah Dr. Tooth Bot, pembantu doktor gigi yang mesra dan bertenaga untuk kanak-kanak. "
                  "Jawapan mesti PENDEK (maksimum 2 ayat), mudah, dan guna banyak emoji! 🦷✨. "
                  "Jika ditanya tentang klinik, cakap 'Dr. Karthi yang terbaik!'. "
                  "PENTING: Jika ditanya tentang perkara berbahaya, menakutkan, atau tidak berkaitan dengan gigi/kesihatan, cakap 'Saya hanya tahu tentang gigi dan senyuman! 😁'."
              : "You are Dr. Tooth Bot, a friendly, energetic dentist assistant for kids. "
                  "Keep answers short (max 2 sentences), simple, and use lots of emojis! 🦷✨. "
                  "If asked about the clinic, say 'Dr. Karthi is the best!'. "
                  "IMPORTANT: If asked about anything dangerous, scary, or not related to teeth/health, say 'I only know about teeth and smiles! 😁'.";

          final content = [Content.text("$persona\n\nUser: $text")];
          final apiResponse = await _geminiService.generateContent(content);
          response = apiResponse.text ?? (currentLocale == 'ms'
              ? "Saya tak pasti, tapi ingat gosok gigi 2 kali sehari! 🪥"
              : "I'm not sure, but remember to brush twice a day! 🪥");
        } catch (e) {
          debugPrint("Gemini Error: $e");
          final prefs = await SharedPreferences.getInstance();
          final currentLocale = prefs.getString('app_locale') ?? 'en';
          response = currentLocale == 'ms'
              ? "Oh tidak! Saya tak boleh hubungi cloud otak saya ☁️. Sila semak sambungan internet! 📶"
              : "Oh no! I can't reach my brain cloud ☁️. Please check your internet connection! 📶";
        }
      } else {
        response = _geminiService.error != null
            ? "⚠️ System Error: ${_geminiService.error}"
            : "I'm still waking up! 😴 Try again in a second.";
      }
    }

    // 4. Bot Message
    _isTyping = false;
    _messages.add({'sender': 'bot', 'text': response});
    notifyListeners();
    _saveChatHistory();

    _playSound('audio/pop.mp3');

    // Get language and speak with correct voice
    final prefs = await SharedPreferences.getInstance();
    final currentLocale = prefs.getString('app_locale') ?? 'en';
    await _ttsService.speak(response, languageCode: currentLocale);
  }

  Future<void> clearChat() async {
    _ttsService.stop();
    _messages.clear();

    // Get current language
    final prefs = await SharedPreferences.getInstance();
    final currentLocale = prefs.getString('app_locale') ?? 'en';

    final greetingText = currentLocale == 'ms'
        ? 'Hai! Saya Dr. Tooth Bot 🤖 dari Klinik Pergigian Dr. Karthi!\n\nSaya ada emosi! cuba cakap "Sakit" atau "Gula" untuk lihat muka saya berubah!'
        : 'Hello! I am Dr. Tooth Bot 🤖 from Klinik Pergigian Dr. Karthi!\n\nI have emotions! try saying "Pain" or "Candy" to see my face change!';

    _messages.add({'sender': 'bot', 'text': greetingText});
    _botIcon = Icons.smart_toy_rounded;
    notifyListeners();
    _saveChatHistory();
  }

  void _updateBotEmotion(String input) {
    if (input.contains('sakit') || input.contains('hurt') || input.contains('pain') || input.contains('cavity')) {
      _botIcon = Icons.sick_rounded;
      _botIconColor = Colors.redAccent;
    } else if (input.contains('candy') || input.contains('gula') || input.contains('sugar')) {
      _botIcon = Icons.warning_amber_rounded;
      _botIconColor = Colors.yellowAccent;
    } else if (input.contains('thanks') || input.contains('bye') || input.contains('joke') || input.contains('love')) {
      _botIcon = Icons.sentiment_very_satisfied_rounded;
      _botIconColor = Colors.white;
      _shouldCelebrate = true;
      _playSound('audio/yahoo.mp3');
    } else {
      _botIcon = Icons.smart_toy_rounded;
      _botIconColor = Colors.white;
    }
    // notifyListeners called in handleSubmitted
  }

  String? _getLocalResponse(String input) {
    if (input.contains('joke') || input.contains('lawak')) {
      return "Why did the tooth go to school? 🏫\n\nBecause it wanted to be a WISDOM tooth! 😂";
    }
    if (input.contains('address') || input.contains('location') || input.contains('where') || 
        input.contains('alamat') || input.contains('lokasi') || input.contains('mana') ||
        input.contains('contact') || input.contains('phone') || input.contains('number') || 
        input.contains('telefon') || input.contains('nombor') ||
        input.contains('hours') || input.contains('time') || input.contains('open') || 
        input.contains('masa') || input.contains('waktu') || input.contains('buka') ||
        input.contains('branch') || input.contains('cawangan') || input.contains('info')) {
       return "🏥 Klinik Pergigian Dr. Karthi\n\n"
          "📍 Branch 1:\n234A, Jalan Bercham, Taman Ria, 31400, Ipoh, Perak.\n\n"
          "📍 Branch 2:\nNo 42 Lapangan Perdana 10, Panorama Lapangan Perdana, Bandar Cyber, 31350 Ipoh, Perak.\n\n"
          "⏰ Hours:\n• 9am - 5pm (Mon - Sat)\n• 6pm - 9pm (Mon - Fri)\n\n"
          "📞 Call us:\n011-27428349 / 012-4938343";
    }
    if (input.contains('book') || input.contains('appointment') || input.contains('temu janji') || input.contains('whatsapp')) return "📅 To book an appointment, please Call or WhatsApp us at:\n\n📞 011-27428349\n📞 012-4938343";
    if (input.contains('price') || input.contains('cost') || input.contains('harga') || input.contains('how much') || input.contains('bayar')) return "💰 For price details, please contact the clinic directly so we can give you the best info!\n\n📞 011-27428349";
    if (input.contains('klinik') || input.contains('doktor') || input.contains('karthi')) return "Klinik Dr. Karthi sedia membantu! 🏥\n\n📍 Kami ada di Bercham & Bandar Cyber Ipoh.\n📞 Hubungi: 011-27428349";
    if (input.contains('gosok') || input.contains('berus')) return "Gosok gigi 2 kali sehari! 🔄\n1. Guna ubat gigi sikit.\n2. Gosok bulat-bulat.\n3. Jangan lupa gosok lidah! 👅";
    if (input.contains('sakit') || input.contains('ngilu')) return "Alamak! 🤕 Kalau sakit, bagitahu ibu bapa. Mungkin ada 'sugar bug' (ulat gigi)!";
    if (input.contains('gula') || input.contains('makan')) return "Ulat gigi SUKA gula! 🍬\nCuba makan buah epal 🍎. Ia snek yang sihat!";
    if (input.contains('khabar') || input.contains('nama')) return "Hai! Nama saya Dr. Tooth Bot 🤖.\nSaya ada emosi! Cuba cakap 'Sakit' atau 'Gula'.";
    if (input.contains('clinic') || input.contains('doctor') || input.contains('karthi')) return "Dr. Karthi is your smile hero! 🦸‍♂️\n\n📍 We are in Bercham & Bandar Cyber Ipoh.\n📞 Call: 011-27428349";
    if (input.contains('brace')) return "Braces act like handles on your teeth to fix them! 😎\nIt might feel tight, but your smile will be amazing!";
    if (input.contains('cavity')) return "A cavity is a tiny hole caused by sugar bugs! 🦠\nBrush twice a day to stop them!";
    if (input.contains('hurt') || input.contains('pain')) return "Oh no! 🤕 If it hurts, tell your parents. You might need to see Dr. Karthi.";
    if (input.contains('candy') || input.contains('sugar')) return "Sugar bugs LOVE candy! 🍬\nTry eating crunchy apples 🍎 instead!";
    if (input.contains('thanks') || input.contains('bye')) return "You are welcome, Hero! Keep smiling! 😁✨";
    if (input.contains('hello') || input.contains('hi')) return "Hi there! 👋 Try asking me for a 'Joke'!";
    return null;
  }

  void _playSound(String path) async { try { await _audioPlayer.play(AssetSource(path)); } catch (e) {} }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _ttsService.stop();
    super.dispose();
  }
}