import 'package:flutter/material.dart';
import 'auth/landing_page.dart';

void main() {
  runApp(CineLogApp());
}

class CineLogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineLog',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          secondary: Colors.tealAccent,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Poppins',
        ),
      ),
      home: LandingPage(),
    );
  }
}