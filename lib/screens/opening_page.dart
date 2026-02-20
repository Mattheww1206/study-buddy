import 'package:flutter/material.dart';

class OpeningPage extends StatelessWidget {
  const OpeningPage ({Key? key}) : super(key : key);

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  backgroundColor: const Color(0xFF16056B),
  body: const Center(
    child: Text(
      "Welcome to StudyBuddy",
      style: TextStyle(color: Colors.white, fontSize: 24),
    ),
  ),
);
      
  }
}