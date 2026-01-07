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
      notifyListeners();
    } catch (e) {
      // Handle initialization error
      _isReady = false;
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
    notifyListeners();

    await _runInference(file);
  }

  Future<void> _runInference(File image) async {
    _isProcessing = true;
    _results = null;
    notifyListeners();

    try {
      final results = await _aiService.runInference(image);
      _results = results;
    } catch (e) {
      // Check if it's a no teeth detected exception to handle differently
      if (e is NoTeethDetectedException) {
        // Set a special result to indicate no teeth detected
        _results = {'no_teeth_detected': 100.0};
        // Don't rethrow for this specific case - just update the UI
      } else {
        // For other errors, you might want to set an error state
        // Or handle differently based on your needs
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void resetScan() {
    _selectedImage = null;
    _results = null;
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