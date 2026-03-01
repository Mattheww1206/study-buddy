import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: const Color.fromARGB(255, 243, 233, 33),
          child: Text('this is create page',
          style: TextStyle(
            fontSize: 25
          ),
          ),
        ),
      ),
    );
  }
}