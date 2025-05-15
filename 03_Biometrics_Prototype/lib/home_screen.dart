import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'auth_service.dart';
import 'constants.dart';
import 'model_service.dart';
import 'sensor_manager.dart';
import 'forced_logout_dialog.dart';

enum AuthStatus { verified, checking, mismatch }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthStatus _status = AuthStatus.checking;
  double _confidence = 0.0;
  Timer? _autoCheckTimer;
  Timer? _countdownTimer;
  Duration _nextCheck = AppConstants.autoCheckInterval;
  int _mismatchCount = 0;
  bool _monitoring = true;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    // Initial immediate check
    _performCheck();
    // Schedule periodic auto-check
    _autoCheckTimer = Timer.periodic(AppConstants.autoCheckInterval, (_) {
      if (_monitoring) _performCheck();
    });
    // Countdown for UI
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        final secs = _nextCheck.inSeconds - 1;
        _nextCheck = Duration(seconds: secs >= 0 ? secs : 0);
        if (_nextCheck.inSeconds == 0) {
          _nextCheck = AppConstants.autoCheckInterval;
        }
      });
    });
  }

  Future<void> _performCheck() async {
    setState(() {
      _status = AuthStatus.checking;
    });
    // Get the most recent 100×21 window
    final window = SensorManager().getBufferedWindow();
    final conf = ModelService.predictConfidence(window);
    setState(() => _confidence = conf);

    if (conf >= AppConstants.confidenceThreshold) {
      setState(() => _status = AuthStatus.verified);
      _mismatchCount = 0;
    } else {
      // Mismatch: retry up to maxMismatchRetries
      for (int i = 0; i < AppConstants.maxMismatchRetries; i++) {
        final retryWindow = SensorManager().getBufferedWindow();
        final retryConf = ModelService.predictConfidence(retryWindow);
        if (retryConf >= AppConstants.confidenceThreshold) {
          setState(() {
            _status = AuthStatus.verified;
            _confidence = retryConf;
          });
          return;
        }
      }
      setState(() => _status = AuthStatus.mismatch);
      _showForcedLogoutDialog();
    }
  }

  void _showForcedLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ForcedLogoutDialog(
        onLoginPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        onCancel: () {
          Navigator.pop(context);
          setState(() => _status = AuthStatus.checking);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    switch (_status) {
      case AuthStatus.verified:
        statusText = 'VERIFIED';
        statusColor = Colors.green;
        break;
      case AuthStatus.checking:
        statusText = 'CHECKING';
        statusColor = Colors.blue;
        break;
      case AuthStatus.mismatch:
        statusText = 'MISMATCH';
        statusColor = Colors.red;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hey, ${AuthService.currentUser?.email ?? ''}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            Text(statusText,
                style: TextStyle(fontSize: 24, color: statusColor)),
            SizedBox(height: 16),
            CircularPercentIndicator(
              radius: 100,
              lineWidth: 12,
              percent: _confidence.clamp(0.0, 1.0),
              center: Text('${(_confidence * 100).toStringAsFixed(1)}%'),
              progressColor: statusColor,
            ),
            SizedBox(height: 16),
            Text('Next Check In: ${_nextCheck.inMinutes.remainder(60).toString().padLeft(2,'0')}:${_nextCheck.inSeconds.remainder(60).toString().padLeft(2,'0')}'),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Monitoring Activity'),
              value: _monitoring,
              onChanged: (val) {
                setState(() => _monitoring = val);
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _monitoring ? _performCheck : null,
              child: Text('Force Check Now'),
            ),
          ],
        ),
      ),
    );
  }
}