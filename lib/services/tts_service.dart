import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  String _currentLanguage = "en-US";

  Future<void> init() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.1); // Friendly bot pitch
    await _flutterTts.setSpeechRate(0.5); // Slower for kids
  }

  /// Set the TTS language (en-US or ms-MY)
  Future<void> setLanguage(String languageCode) async {
    // Convert 'en' or 'ms' to full locale code
    final locale = languageCode == 'ms' ? 'ms-MY' : 'en-US';
    if (_currentLanguage != locale) {
      _currentLanguage = locale;
      await _flutterTts.setLanguage(locale);
    }
  }

  Future<void> speak(String text, {String? languageCode}) async {
    await stop();

    // If language code provided, set it before speaking
    if (languageCode != null) {
      await setLanguage(languageCode);
    }

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