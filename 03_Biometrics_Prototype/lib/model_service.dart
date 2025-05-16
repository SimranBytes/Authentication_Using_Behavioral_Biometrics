import 'dart:async';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'constants.dart';

/// Service to load the TFLite model and perform inference.
class ModelService {
  ModelService._();

  static Interpreter? _interpreter;

  /// Initialize the TFLite Interpreter. Call once (e.g. in main) before using.
  static Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(AppConstants.modelAssetPath);
    } catch (e) {
      throw Exception('Failed to load TFLite model: \$e');
    }
  }

  /// Runs inference on a single window of sensor data.
  ///
  /// [window] must be a List of length 100, each sublist of length 21,
  /// matching the model's input shape [1, 100, 21].
  /// Returns a confidence score between 0.0 and 1.0.
  static double predictConfidence(List<List<double>> window) {
    if (_interpreter == null) {
      throw Exception('TFLite Interpreter not initialized.');
    }

    // Prepare input as [1, 100, 21]
    final input = <dynamic>[window];

    // Prepare output buffer for a single float value
    final output = List<double>.filled(1, 0.0);

    // Run inference
    _interpreter!.run(input, output);

    // Return the raw confidence (already 0.0–1.0)
    return output[0];
  }

  /// Dispose the interpreter when no longer needed.
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
// import 'dart:math';
//
// /// A stubbed ModelService that returns random confidence values in [0.0, 1.0).
// class ModelService {
//   ModelService._();
//   static final Random _rand = Random();
//
//   /// No-op initialization for stubbed service.
//   static Future<void> initialize() async {
//     // Stub: skip TFLite initialization
//   }
//
//   /// Returns a random confidence between 0.0 and 1.0 (so some checks will "fail").
//   static double predictConfidence(List<List<double>> window) {
//     return _rand.nextDouble();
//   }
// }