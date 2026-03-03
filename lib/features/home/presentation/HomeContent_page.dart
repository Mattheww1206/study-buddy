import 'package:flutter/material.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
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

      body: Stack(
        children: [
          Container(
            height: 350,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(148, 185, 255, 1),
                  Color.fromRGBO(205, 255, 216, 1),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
        ],
      ),


    );
  }
}