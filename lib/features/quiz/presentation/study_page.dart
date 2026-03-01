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
      body: Center(
        child: Container(
          color: const Color.fromARGB(255, 238, 14, 141),
          child: Text('this is study page',
          style: TextStyle(
            fontSize: 25
          ),
          ),
        ),
      ),
    );
  }
}