import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'permissions.dart'; // Import the permissions file

class SensorManager {
  List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  List<List<dynamic>> _sensorData = [];
  List<Offset> _touchStrokeData = [];
  StreamController<List<dynamic>> _dataController = StreamController.broadcast();

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
    _streamSubscriptions.add(accelerometerEvents.listen((event) {
      double lastTouchX = _touchStrokeData.isNotEmpty ? _touchStrokeData.last.dx : 0.0;
      double lastTouchY = _touchStrokeData.isNotEmpty ? _touchStrokeData.last.dy : 0.0;
      List<dynamic> sensorEvent = [
        DateTime.now().toIso8601String(),
        event.x,
        event.y,
        event.z,
        lastTouchX,
        lastTouchY
      ];
      _sensorData.add(sensorEvent);
      _dataController.add(sensorEvent); // Broadcast sensor data
      print("Data added: $sensorEvent");
    }));
  }

  Future<void> saveDataToFile() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final filePath = '${directory.path}/sensor_data.csv';
      final File file = File(filePath);
      final List<List<dynamic>> rows = List<List<dynamic>>.from(_sensorData);
      rows.insert(0, ["Timestamp", "Accelerometer X", "Accelerometer Y", "Accelerometer Z", "Last Touch X", "Last Touch Y"]);
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
