import 'package:flutter/material.dart';
import 'views/home_screen.dart';

void main() {
  runApp(StreamixApp());
}

class StreamixApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Streamix Pro',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0F172A),
        primarySwatch: Colors.red,
      ),
      home: HomeScreen(),
    );
  }
}
