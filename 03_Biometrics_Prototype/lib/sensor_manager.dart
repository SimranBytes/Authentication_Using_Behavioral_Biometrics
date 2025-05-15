import 'dart:async';
import 'dart:collection';
import 'package:sensors_plus/sensors_plus.dart';

/// Manages live sensor streams and buffers the last 100 samples of 21 features.
class SensorManager {
  SensorManager._();
  static final SensorManager instance = SensorManager._();

  // ─── Internal Buffer ─────────────────────────────────────────────────────
  /// Circular buffer storing recent samples [featureLength = 21].
  final Queue<List<double>> _windowBuffer = Queue<List<double>>();

  // ─── Sensor Subscriptions ────────────────────────────────────────────────
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Starts collecting sensor data. Call once (e.g. in TrainingScreen.initState).
  void startCollection() {
    // Accelerometer: 3 axes
    _subscriptions.add(
      accelerometerEvents.listen((event) {
        _recordSample(0, [event.x, event.y, event.z]);
      }),
    );
    // Gyroscope: 3 axes
    _subscriptions.add(
      gyroscopeEvents.listen((event) {
        _recordSample(1, [event.x, event.y, event.z]);
      }),
    );
    // Magnetometer: 3 axes
    _subscriptions.add(
      magnetometerEvents.listen((event) {
        _recordSample(2, [event.x, event.y, event.z]);
      }),
    );
    // Rotation Vector: use userAccelerometerEvents as proxy
    _subscriptions.add(
      userAccelerometerEvents.listen((event) {
        _recordSample(3, [event.x, event.y, event.z]);
      }),
    );
    // Tilt Detector: reuse gyroscopeEvents for tilt proxy
    _subscriptions.add(
      gyroscopeEvents.listen((event) {
        _recordSample(4, [event.x, event.y, event.z]);
      }),
    );
    // Auto-Rotation: reuse userAccelerometerEvents for rotation proxy
    _subscriptions.add(
      userAccelerometerEvents.listen((event) {
        _recordSample(5, [event.x, event.y, event.z]);
      }),
    );
    // Motion Sensor: reuse userAccelerometerEvents for motion proxy
    _subscriptions.add(
      userAccelerometerEvents.listen((event) {
        _recordSample(6, [event.x, event.y, event.z]);
      }),
    );
  }

  /// Stops all sensor subscriptions and clears buffer.
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _windowBuffer.clear();
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Returns a fixed-size [100×21] window for model inference.
  /// If fewer than 100 samples are present, pads with zeros at the front.
  List<List<double>> getBufferedWindow() {
    final totalSamples = _windowBuffer.length;
    final padCount = 100 - totalSamples;
    final window = <List<double>>[];
    for (var i = 0; i < padCount; i++) {
      window.add(List<double>.filled(21, 0.0));
    }
    window.addAll(_windowBuffer.toList());
    return window;
  }

  // ─── Internal Helpers ────────────────────────────────────────────────────

  /// Records a feature triplet at [featureGroupIndex] into the buffer.
  /// featureGroupIndex 0–6 corresponds to each 3-value sensor group.
  void _recordSample(int featureGroupIndex, List<double> values) {
    // Each full sample is 7 groups × 3 = 21 features.
    // Prepare a zero-filled 21-length list.
    final sample = List<double>.filled(21, 0.0);
    // Insert the 3 values into the correct group slot.
    for (var i = 0; i < 3; i++) {
      sample[featureGroupIndex * 3 + i] = values[i];
    }
    // Add to circular buffer
    if (_windowBuffer.length >= 100) {
      _windowBuffer.removeFirst();
    }
    _windowBuffer.addLast(sample);
  }
}