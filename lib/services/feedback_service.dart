import 'package:flutter/material.dart';
import '../config/app_config.dart';

class FeedbackService {
  // Returns translation key for feedback message
  static String getFeedback(Map<String, double>? results) {
    if (results == null) return "noAnalysisYet";

    // Check if no teeth were detected
    if (results.containsKey('no_teeth_detected')) {
      return "noTeethDetectedFeedback";
    }

    List<String> messages = [];

    if (results['Calculus'] != null && results['Calculus']! > AppConfig.calculusDetectionThreshold) {
      messages.add("mildPlaqueDetected");
    }
    if (results['Caries'] != null && results['Caries']! > AppConfig.cariesDetectionThreshold) {
      messages.add("possibleCavityDetected");
    }
    if (results['Stain'] != null && results['Stain']! > AppConfig.stainDetectionThreshold) {
      messages.add("minorStainingDetected");
    }
    if (results['Healthy_Teeth'] != null && results['Healthy_Teeth']! > AppConfig.healthyTeethDetectionThreshold) {
      messages.add("teethLookHealthy");
    }

    if (messages.isEmpty) return "unclearRetakePhoto";
    // Return combined key - will be translated in UI layer
    return messages.join("|"); // Use pipe separator for multiple messages
  }

  static Color getConditionColor(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('no_teeth_detected')) return Colors.orange;
    if (lower.contains('healthy')) return Colors.green;
    if (lower.contains('caries')) return Colors.red;
    if (lower.contains('stain')) return Colors.orange;
    if (lower.contains('calculus')) {
      return Colors.amber;
    }
    return Colors.blue;
  }
}


