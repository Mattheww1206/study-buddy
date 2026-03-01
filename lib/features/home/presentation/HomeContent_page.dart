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
      body: Center(
        child: Container(
          color: Colors.blue,
          child: Text('this is home page',
          style: TextStyle(
            fontSize: 25
          ),
          ),
        ),
      ),
    );
  }
}