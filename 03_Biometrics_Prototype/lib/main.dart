import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'model_service.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'training_screen.dart';
import 'home_screen.dart';
import 'retraining_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with your generated options
  await AuthService.initialize();

  // Initialize TFLite (safe‐guarded if CAST op not yet supported)
  try {
    await ModelService.initialize();
  } catch (e, st) {
    debugPrint('Warning: TFLite initialize failed: $e\n$st');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Behavioral Biometrics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login':      (ctx) => LoginPage(),
        '/signup':     (ctx) => SignupPage(),
        '/training':   (ctx) => TrainingScreen(),
        '/home':       (ctx) => HomeScreen(),
        '/retraining': (ctx) => RetrainingScreen(),
      },
    );
  }
}
