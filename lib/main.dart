import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task is running");
    // You can add logic here to run your background task, e.g., saving or collecting sensor data
    return Future.value(true);
  });
}

void main() {
  // Initialize the app and WorkManager
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager for background tasks
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  // Register a periodic task to run in the background (15 minutes is the minimum interval for Android)
  Workmanager().registerPeriodicTask(
    "sensorTask",
    "collectSensorData",
    frequency: Duration(minutes: 15),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}
