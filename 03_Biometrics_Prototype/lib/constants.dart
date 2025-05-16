import 'package:flutter/material.dart';

/// Holds all configurable, app-wide constants for the Behavioral Biometrics prototype.
class AppConstants {
  // ─── Training Durations ───────────────────────────────────────────────────
  static const Duration initialTrainingDuration = Duration(minutes: 1);
  static const Duration reTrainingDuration     = Duration(minutes: 5);

  // ─── Confidence & Retry ────────────────────────────────────────────────────
  static const double confidenceThreshold = 0.80;
  static const int    maxMismatchRetries  = 9;

  // ─── Automatic Checks ──────────────────────────────────────────────────────
  static const Duration autoCheckInterval = Duration(seconds: 60);

  // ─── Testing / Overrides ───────────────────────────────────────────────────
  /// When true, every sign-in/up call bypasses real Firebase and uses
  /// anonymous auth instead. Flip this to false once you’re ready to
  /// troubleshoot real errors.
  static const bool enableTestAutoLogin = false;

  /// Test credentials for override flow (optional)
  static const String testEmail    = 'test@example.com';
  static const String testPassword = 'password123';

  // ─── Asset Paths ──────────────────────────────────────────────────────────
  static const String modelAssetPath = 'assets/models/gru_model.tflite';

  // ─── UI Strings ──────────────────────────────────────────────────────────
  static const String loginErrorMsg         = 'Login failed. Please try again.';
  static const String serviceUnavailableMsg = 'Service not available as of now!';
}