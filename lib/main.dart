import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';

/// Define the MethodChannel to communicate with native Android
const MethodChannel _channel = MethodChannel('com.example.biometrics/gestures');

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task is running");
    // Logic for background task (e.g., saving or collecting sensor data)
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
      home: GestureScreen(),  // Navigate directly to GestureScreen for testing
    );
  }
}

/// GestureScreen listens for gesture events via MethodChannel and updates the UI accordingly
class GestureScreen extends StatefulWidget {
  @override
  _GestureScreenState createState() => _GestureScreenState();
}

class _GestureScreenState extends State<GestureScreen> {
  String _gestureMessage = "No gestures detected";  // Default message

  @override
  void initState() {
    super.initState();
    // Set up the MethodChannel to receive gesture events from native Android
    _channel.setMethodCallHandler(_onGestureDetected);
  }

  /// This method is called whenever a gesture event is received
  Future<void> _onGestureDetected(MethodCall call) async {
    if (call.method == "onGestureDetected") {
      setState(() {
        _gestureMessage = call.arguments;  // Update the UI with the gesture event
      });
    }
  }

  /// Open the Accessibility Settings for the user to enable the service
  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('startService');
    } on PlatformException catch (e) {
      print("Failed to open settings: ${e.message}");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gesture Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _gestureMessage,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: openAccessibilitySettings,
              child: Text('Enable Accessibility Service'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
              child: Text('Go to Home Page'),
            ),
          ],
        ),
      ),
    );
  }
}
