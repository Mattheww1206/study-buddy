import 'package:flutter/material.dart';
import 'package:studybuddy/widgets/custom_button.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
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
      body: Center(
        child: Container(
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
          child: Column(
                children: [
                  Text(
                    'this is create page',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 300,
                  ),
                  CustomButton(
                    text: '+',
                    fontSize: 40,
                    height: 50,
                    width: 120,
                  )
                ],
              ),
        ),
      ),
    );
  }
}