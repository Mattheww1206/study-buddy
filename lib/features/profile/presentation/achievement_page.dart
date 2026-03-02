import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B70),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Achievement',
          style: GoogleFonts.lora( 
            fontWeight:FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),
        ),
      )
     );
  }
}