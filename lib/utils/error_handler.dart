import 'package:flutter/material.dart';

class ErrorHandler {
  static void showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
  
  static String getErrorMessage(Object error) {
    if (error is String) {
      return error;
    } else if (error.toString().contains('AiNotLoadedException')) {
      return "AI model not loaded. Please restart the app.";
    } else if (error.toString().contains('InvalidImageException')) {
      return "Invalid image format. Please select a different image.";
    } else if (error.toString().contains('AiInferenceException')) {
      return "Error processing the image. Please try again.";
    } else if (error.toString().contains('AiModelLoadException')) {
      return "Failed to load AI model. Please check your assets.";
    } else {
      return "An unexpected error occurred: ${error.toString()}";
    }
  }
}