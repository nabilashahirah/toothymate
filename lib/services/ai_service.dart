import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../config/app_config.dart';

class AiService {
  Interpreter? _interpreter;

  final List<String> labels = [
    'Calculus',
    'Caries',
    'Healthy_Teeth',
    'Stain',
    'not_teeth',  // New class for non-teeth images
  ];

  bool get isLoaded => _interpreter != null;

  // Note: With the new model that includes "Not_Teeth" class,
  // we no longer need the heuristic detection methods.
  // The model itself handles teeth vs non-teeth classification.

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(AppConfig.aiModelPath);
    } catch (e) {
      throw AiModelLoadException('Failed to load AI model: $e');
    }
  }

  Future<Map<String, double>> runInference(File imageFile) async {
    if (_interpreter == null) {
      throw AiNotLoadedException('AI model not loaded. Call loadModel() first.');
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw InvalidImageException('Could not decode image file');
      }

      img.Image oriented = img.bakeOrientation(image);
      img.Image resized = img.copyResizeCropSquare(oriented, AppConfig.modelInputSize);

      var input = _imageToFloat32(resized).reshape([1, AppConfig.modelInputSize, AppConfig.modelInputSize, 3]);
      var output = List.filled(labels.length, 0.0).reshape([1, labels.length]);

      _interpreter!.run(input, output);

      Map<String, double> results = {};
      for (int i = 0; i < labels.length; i++) {
        results[labels[i]] = output[0][i] * 100;
      }

      // Check if the model detected "not_teeth" with high confidence
      if (results['not_teeth'] != null && results['not_teeth']! > 50.0) {
        throw NoTeethDetectedException('No teeth detected in the image. Please take a photo of your teeth.');
      }

      return results;
    } catch (e) {
      if (e is NoTeethDetectedException) {
        rethrow; // Re-throw the teeth detection exception
      }
      throw AiInferenceException('Failed to run inference: $e');
    }
  }

  Float32List _imageToFloat32(img.Image image) {
    var buffer = Float32List(AppConfig.modelInputSize * AppConfig.modelInputSize * 3);
    int index = 0;

    for (int y = 0; y < AppConfig.modelInputSize; y++) {
      for (int x = 0; x < AppConfig.modelInputSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[index++] = (img.getRed(pixel) - 127.5) / 127.5;
        buffer[index++] = (img.getGreen(pixel) - 127.5) / 127.5;
        buffer[index++] = (img.getBlue(pixel) - 127.5) / 127.5;
      }
    }
    return buffer;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

// Custom exceptions for better error handling
class AiException implements Exception {
  final String message;
  AiException(this.message);
  @override
  String toString() => 'AiException: $message';
}

class AiModelLoadException extends AiException {
  AiModelLoadException(super.message);
}

class AiNotLoadedException extends AiException {
  AiNotLoadedException(super.message);
}

class InvalidImageException extends AiException {
  InvalidImageException(super.message);
}

class AiInferenceException extends AiException {
  AiInferenceException(super.message);
}

class NoTeethDetectedException extends AiException {
  NoTeethDetectedException(super.message);
}
