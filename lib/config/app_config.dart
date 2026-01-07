/// Contains all the app level configurations and constants
class AppConfig {
  // AI Model Configuration
  static const String aiModelPath = 'assets/models/toothymate_classifier.tflite';
  static const int modelInputSize = 224;
  
  // Thresholds and Constants
  static const double aiConfidenceThreshold = 30.0; // Minimum confidence to show results
  static const int maxAdviceCount = 2; // Show at most 2 advice cards
  static const double calculusDetectionThreshold = 30.0;
  static const double cariesDetectionThreshold = 30.0;
  static const double stainDetectionThreshold = 30.0;
  static const double healthyTeethDetectionThreshold = 50.0;
  
  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 800);
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 15.0;
  static const double buttonHeight = 60.0;
  
  // App Information
  static const String appName = 'ToothyMate';
  static const String appVersion = '1.0.1';
}