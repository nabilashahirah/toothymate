import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import '../services/ai_service.dart';
import '../services/camera_service.dart';
import '../services/image_service.dart';

class AiScanProvider extends ChangeNotifier {
  // Services
  late final AiService _aiService;
  late final CameraService _cameraService;
  late final ImageService _imageService;

  // State
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  Map<String, double>? _results;
  Map<String, double>? get results => _results;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  bool _isReady = false;
  bool get isReady => _isReady;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AiScanProvider() {
    _aiService = AiService();
    _cameraService = CameraService();
    _imageService = ImageService();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _aiService.loadModel();
      await _cameraService.initialize();
      _isReady = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      // Handle initialization error
      _isReady = false;
      _errorMessage = 'aiInitError'; // Translation key
      notifyListeners();
    }
  }

  Future<void> capturePhoto() async {
    final XFile? photo = await _cameraService.capture();
    if (photo == null) return;

    final file = File(photo.path);
    _selectedImage = file;
    _isProcessing = true;
    _results = null;
    _errorMessage = null;
    notifyListeners();

    await _runInference(file);
  }

  Future<void> pickImage() async {
    final image = await _imageService.pickFromGallery();
    if (image == null) return;

    final file = File(image.path);
    _selectedImage = file;
    _isProcessing = true;
    _results = null;
    _errorMessage = null;
    notifyListeners();

    await _runInference(file);
  }

  Future<void> _runInference(File image) async {
    _isProcessing = true;
    _results = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _aiService.runInference(image);
      _results = results;
      _errorMessage = null;
    } catch (e) {
      // Handle different types of errors with translation keys
      if (e is NoTeethDetectedException) {
        // Set a special result to indicate no teeth detected
        _results = {'no_teeth_detected': 100.0};
        _errorMessage = null;
      } else if (e is AiNotLoadedException) {
        // AI model not loaded
        _results = null;
        _errorMessage = 'aiModelNotLoaded';
      } else if (e is InvalidImageException) {
        // Invalid image format
        _results = null;
        _errorMessage = 'invalidImage';
      } else if (e is AiInferenceException) {
        // Inference failed
        _results = null;
        _errorMessage = 'aiInferenceFailed';
      } else {
        // Unknown error
        _results = null;
        _errorMessage = 'unexpectedError';
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void resetScan() {
    _selectedImage = null;
    _results = null;
    _errorMessage = null;
    notifyListeners();
  }

  void switchCamera() async {
    await _cameraService.switchCamera();
    notifyListeners();
  }

  // Expose the camera service for use in UI
  CameraService get cameraService => _cameraService;

  @override
  void dispose() {
    _cameraService.dispose();
    _aiService.dispose();
    super.dispose();
  }
}