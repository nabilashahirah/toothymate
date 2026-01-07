import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';
import '../services/camera_service.dart';
import '../services/image_service.dart';

class AppProvider extends ChangeNotifier {
  // Singleton pattern to ensure services are shared across app
  static final AppProvider _instance = AppProvider._internal();
  factory AppProvider() => _instance;
  AppProvider._internal();

  // Services
  late final AiService aiService;
  late final CameraService cameraService;
  late final ImageService imageService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    aiService = AiService();
    cameraService = CameraService();
    imageService = ImageService();

    try {
      await aiService.loadModel();
      await cameraService.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  void dispose() {
    cameraService.dispose();
    aiService.dispose();
    super.dispose();
  }
}