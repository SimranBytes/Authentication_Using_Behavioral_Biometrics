import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'constants.dart';
import 'sensor_manager.dart';

class RetrainingScreen extends StatefulWidget {
  @override
  _RetrainingScreenState createState() => _RetrainingScreenState();
}

class _RetrainingScreenState extends State<RetrainingScreen> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = AppConstants.reTrainingDuration;

    // Start collecting sensor data for re-training
    SensorManager().startCollection();

    // Start countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = Duration(seconds: _remaining.inSeconds - 1);
        } else {
          _timer?.cancel();
          // Stop collecting and navigate back to Home
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = AppConstants.reTrainingDuration.inSeconds;
    final elapsedSeconds = totalSeconds - _remaining.inSeconds;
    final percent = elapsedSeconds / totalSeconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Re-Training Model'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Re-training in progress',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              CircularPercentIndicator(
                radius: 120,
                lineWidth: 13,
                percent: percent.clamp(0.0, 1.0),
                center: Text(
                  _formatDuration(_remaining),
                  style: const TextStyle(fontSize: 24),
                ),
                progressColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Collecting sensor data for re-training...',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}