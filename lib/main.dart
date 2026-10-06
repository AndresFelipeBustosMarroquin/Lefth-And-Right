import 'package:flutter/material.dart';
import 'package:left_and_right/features/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Left and Right',
      home: RegisterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
