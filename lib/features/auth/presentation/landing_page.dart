import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
        statusBarColor: Color.fromARGB(255, 254, 254, 255),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color.fromARGB(255, 255, 255, 255),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 82, 76, 146),
                Color.fromRGBO(246, 246, 247, 1),
                Color.fromARGB(255, 124, 117, 198)
              ],
              stops: [0, 0.5, 1.0]
            )
          ),
          // margin: EdgeInsets.symmetric(vertical: 70),
   
          child: Column(
            children: [
              const  SizedBox(height: 100),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: const Color(0xFF4A449A),
                fontSize: 32,
                height: 66,
                width: 279,
                onTap: () {
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