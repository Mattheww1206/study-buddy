import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/services/notification_service.dart';
import 'package:studybuddy/widgets/custom_button.dart';



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
        statusBarColor: const Color(0xFFFAEEFF),
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF), 
      body: Center(
          child: Column(
            children: [
              const  SizedBox(height: 100),
              Image(
              image: const AssetImage('assets/study.png'),
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
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
               ),
              ),
              CustomButton(
                text: 'Create Account',
                backgroundColor: Theme.of(context).colorScheme.secondary,
                textColor: Colors.white,
                fontSize: 32,
                height: 66,
                width: 279,
                onTap: () {
                  Navigator.pushNamed(context, 'register');
                },
              ),
               SizedBox(
                height: 25,
              ),
              CustomButton(
                text: 'Login',
                backgroundColor: const Color(0xFF4A449A),
                textColor: const Color.fromARGB(255, 255, 255, 255),
                fontSize: 32,
                height: 66,
                width: 279,
                onTap: ()  async {
                  Navigator.pushNamed(context, 'login');
                },
              ),
            ],
          ),
        ),
      );
  }
}