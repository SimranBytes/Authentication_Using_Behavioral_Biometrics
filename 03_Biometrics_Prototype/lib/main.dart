import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'model_service.dart';
import 'constants.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'training_screen.dart';
import 'home_screen.dart';
import 'retraining_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  await ModelService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/training': (context) => TrainingScreen(),
        '/home': (context) => HomeScreen(),
        '/retraining': (context) => RetrainingScreen(),
      },
    );
  }
}