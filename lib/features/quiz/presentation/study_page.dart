import 'package:flutter/material.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0068),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/studybuddy-logo.png',
          height: 95, 
          fit: BoxFit.contain,
        ),
      ),
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(148, 185, 255, 1), 
              Color.fromRGBO(205, 255, 216, 1), 
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'this is study page',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
        ),
      ),
    );
  }
}