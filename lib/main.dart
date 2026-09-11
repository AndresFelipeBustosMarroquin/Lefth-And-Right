import 'package:flutter/material.dart';
import 'package:left_and_right/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Left and Right',
      home: const LoginScreen(),
    );
  }
}
