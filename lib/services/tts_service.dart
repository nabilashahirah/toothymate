import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> init() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.1); // Friendly bot pitch
    await _flutterTts.setSpeechRate(0.5); // Slower for kids
  }

  Future<void> speak(String text) async {
    await stop();
    if (text.isNotEmpty) {
      // 🧹 Remove emojis so the bot doesn't read them out
      final cleanText = text.replaceAll(RegExp('[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true), '');
      await _flutterTts.speak(cleanText);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}