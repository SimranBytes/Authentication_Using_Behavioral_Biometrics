import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'permissions.dart';

class SensorManager {
  List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  List<List<dynamic>> _sensorData = [];
  List<Offset> _touchStrokeData = [];
  StreamController<List<dynamic>> _dataController = StreamController.broadcast();

  double? _accelerometerX, _accelerometerY, _accelerometerZ;
  double? _gyroscopeX, _gyroscopeY, _gyroscopeZ;
  double? _magnetometerX, _magnetometerY, _magnetometerZ;
  double? _rotationVectorX, _rotationVectorY, _rotationVectorZ;
  double? _tiltX, _tiltY, _tiltZ;
  double? _autoRotationX, _autoRotationY, _autoRotationZ;
  double? _motionX, _motionY, _motionZ;

  Stream<List<dynamic>> get dataStream => _dataController.stream;

  Future<void> startCollection(BuildContext context) async {
    //bool granted = await requestStoragePermission(); // Call the function from permissions.dart
    if (true) {
      _collectSensorData();
      print('Data collection started.');
    } else {
      print("Storage permission not granted");
      throw Exception("Storage permission not granted");
    }
  }

  void dispose() {
    _streamSubscriptions.forEach((subscription) => subscription.cancel());
    _dataController.close();
  }

  void updateTouchData(Offset touchPosition) {
    _touchStrokeData.add(touchPosition);
    _dataController.add([
      DateTime.now().toIso8601String(),
      'Touch',
      touchPosition.dx,
      touchPosition.dy
    ]);
  }

  void _collectSensorData() {
    // Accelerometer
    _streamSubscriptions.add(accelerometerEvents.listen((event) {
      _accelerometerX = event.x;
      _accelerometerY = event.y;
      _accelerometerZ = event.z;
      _addSensorData();
    }));

    // Gyroscope
    _streamSubscriptions.add(gyroscopeEvents.listen((event) {
      _gyroscopeX = event.x;
      _gyroscopeY = event.y;
      _gyroscopeZ = event.z;
      _addSensorData();
    }));

    // Magnetometer
    _streamSubscriptions.add(magnetometerEvents.listen((event) {
      _magnetometerX = event.x;
      _magnetometerY = event.y;
      _magnetometerZ = event.z;
      _addSensorData();
    }));

    // Rotation Vector (Non-wakeup)
    _streamSubscriptions.add(userAccelerometerEvents.listen((event) {
      _rotationVectorX = event.x;
      _rotationVectorY = event.y;
      _rotationVectorZ = event.z;
      _addSensorData();
    }));

    // Tilt Detector Wakeup
    _streamSubscriptions.add(gyroscopeEvents.listen((event) {
      _tiltX = event.x;
      _tiltY = event.y;
      _tiltZ = event.z;
      _addSensorData();
    }));

    // Auto-rotation screen orientation sensor (Non-wakeup)
    _streamSubscriptions.add(userAccelerometerEvents.listen((event) {
      _autoRotationX = event.x;
      _autoRotationY = event.y;
      _autoRotationZ = event.z;
      _addSensorData();
    }));

    // Motion Sensor
    _streamSubscriptions.add(userAccelerometerEvents.listen((event) {
      _motionX = event.x;
      _motionY = event.y;
      _motionZ = event.z;
      _addSensorData();
    }));
  }

  void _addSensorData() {
    List<dynamic> sensorEvent = [
      DateTime.now().toIso8601String(),
      _accelerometerX ?? 0, _accelerometerY ?? 0, _accelerometerZ ?? 0,
      _gyroscopeX ?? 0, _gyroscopeY ?? 0, _gyroscopeZ ?? 0,
      _magnetometerX ?? 0, _magnetometerY ?? 0, _magnetometerZ ?? 0,
      _rotationVectorX ?? 0, _rotationVectorY ?? 0, _rotationVectorZ ?? 0,
      _tiltX ?? 0, _tiltY ?? 0, _tiltZ ?? 0,
      _autoRotationX ?? 0, _autoRotationY ?? 0, _autoRotationZ ?? 0,
      _motionX ?? 0, _motionY ?? 0, _motionZ ?? 0
    ];

    _sensorData.add(sensorEvent);
    _dataController.add(sensorEvent); // Broadcast sensor data
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
        "Rotation Vector X", "Rotation Vector Y", "Rotation Vector Z",
        "Tilt Detector X", "Tilt Detector Y", "Tilt Detector Z",
        "Auto-rotation X", "Auto-rotation Y", "Auto-rotation Z",
        "Motion X", "Motion Y", "Motion Z"
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
        final XFile xFile = XFile(filePath); // Create an XFile for sharing
        await Share.shareXFiles([xFile], text: 'Here is the sensor data collected.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File does not exist, cannot share."))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("External storage directory is not available, cannot share."))
      );
    }
  }

  Future<List<List<dynamic>>> readCsvData() async {
    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory?.path}/sensor_data.csv';
      final File file = File(filePath);

      if (await file.exists()) {
        final csvString = await file.readAsString();
        List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
        return csvData;
      } else {
        throw Exception("CSV file does not exist.");
      }
    } catch (e) {
      print("Failed to read CSV file: $e");
      throw Exception("Failed to read CSV file: $e");
    }
  }
}
