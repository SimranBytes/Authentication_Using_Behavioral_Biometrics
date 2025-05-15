// lib/sensor_manager.dart
import 'dart:async';
import 'dart:collection';
import 'package:sensors_plus/sensors_plus.dart';

/// Manages live sensor streams and buffers the last 100 samples of 21 features.
class SensorManager {
  /// Public, unnamed constructor returns the singleton.
  factory SensorManager() => _instance;
  SensorManager._internal();
  static final SensorManager _instance = SensorManager._internal();

  // ─── Internal Buffer ─────────────────────────────────────────────────────
  final Queue<List<double>> _windowBuffer = Queue<List<double>>();

  // ─── Sensor Subscriptions ────────────────────────────────────────────────
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Starts collecting all required sensor streams.
  void startCollection() {
    // Accelerometer
    _subscriptions.add(
      accelerometerEvents.listen((e) => _recordSample(0, [e.x, e.y, e.z])),
    );
    // Gyroscope
    _subscriptions.add(
      gyroscopeEvents.listen((e) => _recordSample(1, [e.x, e.y, e.z])),
    );
    // Magnetometer
    _subscriptions.add(
      magnetometerEvents.listen((e) => _recordSample(2, [e.x, e.y, e.z])),
    );
    // Rotation Vector (proxy)
    _subscriptions.add(
      userAccelerometerEvents.listen((e) => _recordSample(3, [e.x, e.y, e.z])),
    );
    // Tilt (reuse gyroscopeEvents)
    _subscriptions.add(
      gyroscopeEvents.listen((e) => _recordSample(4, [e.x, e.y, e.z])),
    );
    // Auto-Rotation (reuse userAccelerometerEvents)
    _subscriptions.add(
      userAccelerometerEvents.listen((e) => _recordSample(5, [e.x, e.y, e.z])),
    );
    // Motion (reuse userAccelerometerEvents)
    _subscriptions.add(
      userAccelerometerEvents.listen((e) => _recordSample(6, [e.x, e.y, e.z])),
    );
  }

  /// Stops all sensor streams and clears the buffer.
  void dispose() {
    for (final sub in _subscriptions) sub.cancel();
    _subscriptions.clear();
    _windowBuffer.clear();
  }

  /// Returns the latest 100×21 window (pads with zeros if needed).
  List<List<double>> getBufferedWindow() {
    final total = _windowBuffer.length;
    final pad = 100 - total;
    final window = <List<double>>[];
    // pad front
    for (var i = 0; i < pad; i++) {
      window.add(List<double>.filled(21, 0.0));
    }
    window.addAll(_windowBuffer);
    return window;
  }

  void _recordSample(int groupIndex, List<double> values) {
    // Each sample = 7 groups × 3 dims = 21 features
    final sample = List<double>.filled(21, 0.0);
    for (var i = 0; i < 3; i++) {
      sample[groupIndex * 3 + i] = values[i];
    }
    if (_windowBuffer.length >= 100) _windowBuffer.removeFirst();
    _windowBuffer.addLast(sample);
  }
}
