import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF16056B),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16056B),
      body: SafeArea(
        child: Center(
          child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Image.asset(
                  'assets/studybuddy-logo.png',
                  width: 330,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Login',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 38,
                              ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            // Email TextField
                            Padding(
                              padding: const EdgeInsetsGeometry.symmetric(horizontal: 25),
                              child: TextFormField(
                                style: TextStyle(
                                  fontSize: 18
                                ),
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                    fontSize: 18,
                                  ),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none
                                  )
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  return null;
                                }
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                           // Password TextField
                           Padding(
                              padding: const EdgeInsetsGeometry.symmetric(horizontal: 25),
                              child: TextFormField(
                                style: TextStyle(
                                  fontSize: 18
                                ),
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    fontSize: 18,
                                  ),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none
                                  )
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                }
                              ),
                            ),
                             SizedBox(
                              height: 50,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF16056B),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.all(5),
                                minimumSize: Size(140, 12),
                              ),
                              child: Text('Login',
                              style: GoogleFonts.itim(
                               fontSize: 28,
                               ),
                              ),
                              onPressed: () {
                              },
                            ),
                            SizedBox(
                              height: 42,
                            ),
                            Text('New to StudyBuddy?',
                            style: GoogleFonts.itim(
                              fontSize: 28,
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
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                   ),
                  ),
                ]
            ),
          ),
      ),
    );
  }
}