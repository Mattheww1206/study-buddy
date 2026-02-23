import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studybuddy/screens/landing_page.dart';

class OpeningPage extends StatefulWidget {
  const OpeningPage({Key? key}) : super(key: key);

  @override
  State<OpeningPage> createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF16056B),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF16056B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, 'landing');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16056B),
      body: Center(
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Image(
            image: const AssetImage('assets/studybuddy.png'),
            width: 500,
            height: 500,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}