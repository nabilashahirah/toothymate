import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;
  bool isReady = false;
  String? error;

  Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
      // 🛡️ FIX: Aggressively remove hidden spaces/newlines
      final apiKey = dotenv.env['GEMINI_API_KEY']?.replaceAll(RegExp(r'\s+'), '');

      if (apiKey != null && apiKey.isNotEmpty) {
        _model = GenerativeModel(
          model: 'gemini-flash-latest',
          apiKey: apiKey,
          safetySettings: [
            SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low),
            SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.low),
            SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.low),
            SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.low),
          ],
        );
        isReady = true;
        debugPrint("Gemini model initialized successfully");
      } else {
        error = "Key missing. Found: ${dotenv.env.keys.join(', ')}";
      }
    } catch (e) {
      error = "Error loading .env: $e";
      debugPrint("Error loading Gemini: $e");
    }
  }

  Future<GenerateContentResponse> generateContent(Iterable<Content> content) async {
    if (_model == null) throw Exception("Gemini Model not initialized");
    return await _model!.generateContent(content);
  }
}