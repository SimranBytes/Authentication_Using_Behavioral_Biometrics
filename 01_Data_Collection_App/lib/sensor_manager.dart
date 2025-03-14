import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class SensorManager {
  List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  List<List<dynamic>> _sensorData = [];
  List<Offset> _touchStrokeData = [];
  StreamController<List<dynamic>> _dataController = StreamController.broadcast();

  double? _accelerometerX, _accelerometerY, _accelerometerZ;
  double? _gyroscopeX, _gyroscopeY, _gyroscopeZ;
  double? _magnetometerX, _magnetometerY, _magnetometerZ;

  // Variables for storing touch data
  double? _lastTouchX, _lastTouchY;
  double? _currentTouchX, _currentTouchY;

  Stream<List<dynamic>> get dataStream => _dataController.stream;

  Future<void> startCollection(BuildContext context) async {
    _collectSensorData();
    print('Data collection started.');
  }

  void dispose() {
    _streamSubscriptions.forEach((subscription) => subscription.cancel());
    _dataController.close();
  }

  // Function to update touch data in real-time
  void updateTouchData(Offset touchPosition) {
    _touchStrokeData.add(touchPosition);
    _lastTouchX = _currentTouchX ?? 0; // Store last touch
    _lastTouchY = _currentTouchY ?? 0;

    _currentTouchX = touchPosition.dx; // Store current touch X
    _currentTouchY = touchPosition.dy; // Store current touch Y

    _dataController.add([
      DateTime.now().toIso8601String(),
      'CurrentTouch',
      _currentTouchX,
      _currentTouchY
    ]);
  }

  void _collectSensorData() {
    _streamSubscriptions.add(accelerometerEvents.listen((event) {
      _accelerometerX = event.x;
      _accelerometerY = event.y;
      _accelerometerZ = event.z;
      _addSensorData();
    }));

    _streamSubscriptions.add(gyroscopeEvents.listen((event) {
      _gyroscopeX = event.x;
      _gyroscopeY = event.y;
      _gyroscopeZ = event.z;
      _addSensorData();
    }));

    _streamSubscriptions.add(magnetometerEvents.listen((event) {
      _magnetometerX = event.x;
      _magnetometerY = event.y;
      _magnetometerZ = event.z;
      _addSensorData();
    }));
  }

  void _addSensorData() {
    List<dynamic> sensorEvent = [
      DateTime.now().toIso8601String(),
      _accelerometerX ?? 0, _accelerometerY ?? 0, _accelerometerZ ?? 0,
      _gyroscopeX ?? 0, _gyroscopeY ?? 0, _gyroscopeZ ?? 0,
      _magnetometerX ?? 0, _magnetometerY ?? 0, _magnetometerZ ?? 0,
      _lastTouchX ?? 0, _lastTouchY ?? 0, // Last touch data
      _currentTouchX ?? 0, _currentTouchY ?? 0  // Current touch data
    ];

    _sensorData.add(sensorEvent);
    _dataController.add(sensorEvent);
    print("Data added for timestamp ${sensorEvent[0]}: $sensorEvent");
  }

  Future<void> saveDataToFile() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final filePath = '${directory.path}/sensor_data.csv';
      final File file = File(filePath);
      final List<List<dynamic>> rows = List<List<dynamic>>.from(_sensorData);

      rows.insert(0, [
        "Timestamp",
        "Accelerometer X", "Accelerometer Y", "Accelerometer Z",
        "Gyroscope X", "Gyroscope Y", "Gyroscope Z",
        "Magnetometer X", "Magnetometer Y", "Magnetometer Z",
        "Last Touch X", "Last Touch Y",
        "Current Touch X", "Current Touch Y"
      ]);

      String csvData = const ListToCsvConverter().convert(rows);
      await file.writeAsString(csvData);
      print('Data saved to $filePath');
    } else {
      print("External storage directory is not available");
    }
  }

  void stopCollection() {
    _streamSubscriptions.forEach((subscription) => subscription.cancel());
    _streamSubscriptions.clear();
    saveDataToFile();
  }

  Future<void> shareDataFile(BuildContext context) async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final filePath = '${directory.path}/sensor_data.csv';
      final File file = File(filePath);

      if (await file.exists()) {
        final XFile xFile = XFile(filePath);
        await Share.shareXFiles([xFile], text: 'Here is the sensor data collected.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File does not exist, cannot share.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("External storage directory is not available, cannot share.")));
    }
  }

  Future<List<List<dynamic>>> readCsvData() async {
    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory?.path}/sensor_data.csv';
      final File file = File(filePath);

      if (await file.exists()) {
        final csvString = await file.readAsString();
        return const CsvToListConverter().convert(csvString);
      } else {
        throw Exception("CSV file does not exist.");
      }
    } catch (e) {
      print("Failed to read CSV file: $e");
      throw Exception("Failed to read CSV file: $e");
    }
  }
}
