import 'dart:math';
import '../config/app_config.dart';

class AdviceService {
  static const double threshold = AppConfig.aiConfidenceThreshold; // Minimum confidence to show advice
  static const int maxAdviceCount = AppConfig.maxAdviceCount; // Show at most 2 advice cards

  // Returns list of advice with translation keys
  static List<Map<String, String>> getAdviceList(Map<String, double> results) {
    // Check if no teeth were detected
    if (results.containsKey('no_teeth_detected')) {
      return []; // Return empty list when no teeth are detected
    }

    // Filter only results above threshold
    final filtered = results.entries
        .where((e) => e.value >= threshold)
        .toList();

    // Sort by confidence descending
    filtered.sort((a, b) => b.value.compareTo(a.value));

    // Take top N results
    final topResults = filtered.take(maxAdviceCount);

    final List<Map<String, String>> adviceList = [];

    for (var entry in topResults) {
      switch (entry.key) {
        case 'Caries':
          adviceList.add({
            'labelKey': 'cavityLabel',
            'adviceKey': 'cavityAdvice'
          });
          break;
        case 'Calculus': // Updated from 'Calcalus' to match the model output
          adviceList.add({
            'labelKey': 'plaqueLabel',
            'adviceKey': 'plaqueAdvice'
          });
          break;
        case 'Stain':
          adviceList.add({
            'labelKey': 'stainLabel',
            'adviceKey': 'stainAdvice'
          });
          break;
        case 'Healthy_Teeth':
          adviceList.add({
            'labelKey': 'healthyTeethLabel',
            'adviceKey': 'healthyTeethAdvice'
          });
          break;
        default:
          adviceList.add({
            'labelKey': entry.key,
            'adviceKey': 'defaultAdvice'
          });
      }
    }

    // Shuffle so top cards are not always the same order
    adviceList.shuffle(Random());
    return adviceList;
  }
}
