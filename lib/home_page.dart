import 'package:flutter/material.dart';
import 'sensor_manager.dart'; // Ensure this is imported correctly
import 'game_screen.dart'; // Import the GamesScreen


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
                  subtitle: Text(
                      'Accelerometer: (${row[1]}, ${row[2]}, ${row[3]}) Touch: (${row[4]}, ${row[5]})'),
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

  @override
  void dispose() {
    sensorManager.dispose();
    super.dispose();
  }

  // Toggle data collection (No more service call here)
  void _toggleDataCollection() async {
    setState(() {
      _isCollectingData = !_isCollectingData;
    });

    if (_isCollectingData) {
      try {
        await sensorManager.startCollection(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data collection started successfully.")),
        );

        // Navigate to GamesScreen with SensorManager instance
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PianoTilesGame(sensorManager: sensorManager),
          ),
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
        SnackBar(content: Text("Data collection stopped.")),
      );
    }
  }



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

  // Handle sharing the CSV file
  Future<void> _shareCsvFile() async {
    try {
      await sensorManager.shareDataFile(context); // Share the CSV file
    } catch (e) {
      _showErrorDialog("Failed to share the CSV file: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data Collection'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) =>
            sensorManager.updateTouchData(details.localPosition),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _toggleDataCollection,
                child: Text(_isCollectingData
                    ? 'Stop Data Collection'
                    : 'Start Data Collection'),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _shareCsvFile, // Call the share function
                child: Text('Share CSV Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
