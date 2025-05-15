import 'package:flutter/material.dart';

/// Holds all configurable, app-wide constants for the Behavioral Biometrics prototype.
class AppConstants {
  // ─── Training Durations ───────────────────────────────────────────────────
  /// Duration for the initial on-device model training (after signup/login).
  static const Duration initialTrainingDuration = Duration(minutes: 10);
  /// Duration for the re-training after forced re-login.
  static const Duration reTrainingDuration = Duration(minutes: 5);

  // ─── Confidence & Retry ────────────────────────────────────────────────────
  /// Minimum confidence score (0.0–1.0) to classify as VERIFIED.
  static const double confidenceThreshold = 0.70;
  /// Maximum number of consecutive mismatch retries before forced logout.
  static const int maxMismatchRetries = 9;

  // ─── Automatic Checks ──────────────────────────────────────────────────────
  /// Interval between periodic automatic identity checks.
  static const Duration autoCheckInterval = Duration(seconds: 60);

  // ─── Testing / Overrides ───────────────────────────────────────────────────
  /// Enable this to bypass real auth and always succeed (for testing).
  ///
  /// Example usage:
  /// ```dart
  /// if (AppConstants.enableTestAutoLogin) { /* auto-login logic */ }
  /// ```
  static const bool enableTestAutoLogin = false;

  // ─── Asset Paths ──────────────────────────────────────────────────────────
  /// Path inside `pubspec.yaml` under `flutter.assets` for the TFLite model.
  static const String modelAssetPath = 'assets/models/gru_model.tflite';

  // ─── Firebase / Auth ─────────────────────────────────────────────────────
  /// Default test credentials (commented out by default).
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';

  // ─── UI Strings ──────────────────────────────────────────────────────────
  static const String loginErrorMsg = 'Login failed. Please try again.';
  static const String serviceUnavailableMsg = 'Service not available as of now!';
}