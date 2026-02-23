import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart'; // Idinagdag ito para sa link

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailaddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

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
                              child: Text('Register',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 38,
                              ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            // Full Name TextField
                            Padding(
                              padding: const EdgeInsetsGeometry.symmetric(horizontal: 25),
                              child: TextFormField(
                                style: TextStyle(
                                  fontSize: 18
                                ),
                                controller: _fullnameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter Full Name',
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
                                    return 'Name is required';
                                  }
                                  return null;
                                }
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),

                             // Email TextField
                            Padding(
                              padding: const EdgeInsetsGeometry.symmetric(horizontal: 25),
                              child: TextFormField(
                                style: TextStyle(
                                  fontSize: 18
                                ),
                                controller: _emailaddressController,
                                decoration: InputDecoration(
                                  hintText: 'Enter Email Address',
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

                                  if(value.length != 8 || value.length != 16){
                                    return 'Password must be 8 or 16 characters';
                                  }
                                  return null;
                                }
                              ),
                            ),
                             SizedBox(
                              height: 30,
                            ),

                            // Confirm Password TextField
                           Padding(
                              padding: const EdgeInsetsGeometry.symmetric(horizontal: 25),
                              child: TextFormField(
                                style: TextStyle(
                                  fontSize: 18
                                ),
                                controller: _confirmpasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
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
                                    return 'Confirm Password is required';
                                  }

                                  if(_passwordController != _confirmpasswordController ){
                                    return 'Password does not match';
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
                                backgroundColor: Color(0xFFFD9519),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(140, 12),
                              ),
                              child: Text('Create Account',
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
                            
                            
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.itim(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(text: 'Already Studying with us? '),
                                  TextSpan(
                                    text: 'Login',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                         Navigator.pushNamed(context, 'login');
                                        print('Login clicked');
                                      },
                                  ),
                                ],
                              ),
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