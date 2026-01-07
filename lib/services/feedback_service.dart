import 'package:flutter/material.dart';
import '../config/app_config.dart';

class FeedbackService {
  static String getFeedback(Map<String, double>? results) {
    if (results == null) return "No analysis yet";

    // Check if no teeth were detected
    if (results.containsKey('no_teeth_detected')) {
      return "No teeth detected in the image. Please take a clear photo of your teeth.";
    }

    List<String> messages = [];

    if (results['Calculus'] != null && results['Calculus']! > AppConfig.calculusDetectionThreshold) {
      messages.add("Mild plaque detected.");
    }
    if (results['Caries'] != null && results['Caries']! > AppConfig.cariesDetectionThreshold) {
      messages.add("Possible cavity detected.");
    }
    if (results['Stain'] != null && results['Stain']! > AppConfig.stainDetectionThreshold) {
      messages.add("Minor staining detected.");
    }
    if (results['Healthy_Teeth'] != null && results['Healthy_Teeth']! > AppConfig.healthyTeethDetectionThreshold) {
      messages.add("Teeth look healthy!");
    }

    if (messages.isEmpty) return "Unclear. Retake photo.";
    return messages.join(" ");
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


