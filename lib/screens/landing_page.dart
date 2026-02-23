import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

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
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16056B),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 70),
          child: Column(
            children: [
              Image(
              image: const AssetImage('assets/studybuddy.png'),
              width: 400,
              height: 360,
              fit: BoxFit.cover,
              ),
              Transform.translate(
               offset: const Offset(0, -20), 
               child: Text(
                'WELCOME!',
                style: GoogleFonts.itim(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
               ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD9519),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(279, 66)
                ),
                child: Text('Create Account',
                style: GoogleFonts.itim(
                  fontSize: 32,
                ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, 'register');
                },
              ),
               SizedBox(
                height: 20,
              ),
               ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4D7FE),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(279, 66),
                ),
                child: Text('Login',
                style: GoogleFonts.itim(
                  fontSize: 32,
                ),
                ),
                onPressed: () {
                    Navigator.pushNamed(context, 'login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}