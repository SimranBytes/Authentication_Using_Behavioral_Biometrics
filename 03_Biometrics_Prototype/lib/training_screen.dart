import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'constants.dart';
import 'sensor_manager.dart';

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = AppConstants.initialTrainingDuration;
    // Start collecting sensor data
    SensorManager().startCollection();
    // Timer to update countdown each second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = Duration(seconds: _remaining.inSeconds - 1);
        } else {
          _timer?.cancel();
          // Stop collecting and navigate to Home
          SensorManager().dispose();
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final total = AppConstants.initialTrainingDuration.inSeconds;
    final elapsed = total - _remaining.inSeconds;
    final percent = elapsed / total;

    return Scaffold(
      appBar: AppBar(title: Text('Training Model')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Training in progress',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              CircularPercentIndicator(
                radius: 120,
                lineWidth: 13,
                percent: percent.clamp(0.0, 1.0),
                center: Text(
                  _formatDuration(_remaining),
                  style: TextStyle(fontSize: 24),
                ),
                progressColor: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 24),
              Text(
                'Collecting sensor data for training...',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
