import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for MethodChannel
import 'sensor_manager.dart';

class CsvDataScreen extends StatefulWidget {
  @override
  _CsvDataScreenState createState() => _CsvDataScreenState();
}

class _CsvDataScreenState extends State<CsvDataScreen> {
  SensorManager sensorManager = SensorManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSV Data Display'),
      ),
      body: FutureBuilder<List<List<dynamic>>>(
        future: sensorManager.readCsvData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                List<dynamic> row = snapshot.data![index];
                return ListTile(
                  title: Text('Timestamp: ${row[0]}'),
                  subtitle: Text('Accelerometer: (${row[1]}, ${row[2]}, ${row[3]}) Touch: (${row[4]}, ${row[5]})'),
                );
              },
            );
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isCollectingData = false;
  SensorManager sensorManager = SensorManager();

  // Define MethodChannel as a static constant
  static const MethodChannel platform = MethodChannel('com.example.yourapp/background');

  @override
  void dispose() {
    sensorManager.dispose();
    super.dispose();
  }

  // This method toggles data collection and starts/stops the foreground service
  void _toggleDataCollection() async {
    setState(() {
      _isCollectingData = !_isCollectingData;
    });

    if (_isCollectingData) {
      try {
        await sensorManager.startCollection(context);
        // Start the foreground service when data collection begins
        await _startForegroundService();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data collection started successfully."))
        );
      } catch (e) {
        setState(() {
          _isCollectingData = false;
        });
        _showErrorDialog(e.toString());
      }
    } else {
      sensorManager.stopCollection();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data collection stopped."))
      );
    }
  }

  // Method to handle starting the foreground service
  Future<void> _startForegroundService() async {
    try {
      await platform.invokeMethod('startService'); // Call to the native Android service
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  // Error dialog in case of failure
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data Collection'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) => sensorManager.updateTouchData(details.localPosition),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _toggleDataCollection,
                child: Text(_isCollectingData ? 'Stop Data Collection' : 'Start Data Collection'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    _isCollectingData ? Colors.red : Colors.green,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CsvDataScreen()),
                  );
                },
                child: Text('Show Sensor Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
