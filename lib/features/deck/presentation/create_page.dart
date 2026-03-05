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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'this is create page',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D0068),
              ),
            ),
            const SizedBox(height: 50),
            
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D0068), 
                shape: BoxShape.circle,
              ),
              child: IconButton(
                iconSize: 60, 
                padding: const EdgeInsets.all(15), 
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, 'create_deck');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}