import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart'; // Idinagdag ito para sa link
import 'package:studybuddy/widgets/custom_textfield.dart'; 

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
                  width: 265,
                  height: 165,
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
                             CustomTextfield(
                              controller: _fullnameController,
                              hintText: 'Full Name',
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if(value == null || value.isEmpty){
                                  return 'Full Name is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                             // Email TextField
                             CustomTextfield(
                              controller: _emailaddressController,
                              hintText: 'Email Address',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if(value == null || value.isEmpty){
                                  return 'Email Address is required';
                                }
                                if(!value.contains('@')) {
                                  return 'Enter a valid Email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                             // Password TextField
                             CustomTextfield(
                              controller: _passwordController,
                              hintText: 'Password',
                              isPassword: true,
                              validator: (value) {
                                if(value == null || value.isEmpty){
                                  return 'Password is required';
                                }
                                if(value.length < 8){
                                  return 'Password must contain at least 8 characters';
                                }
                                return null;
                              },
                            ),
                             SizedBox(
                              height: 30,
                            ),
                            // Confirm Password TextField
                            CustomTextfield(
                              controller: _confirmpasswordController,
                              hintText: 'Confirm Password',
                              isPassword: true,
                              validator: (value) {
                                if(value == null || value.isEmpty){
                                  return 'Confirm Password is required';
                                }
                                if(_passwordController != _confirmpasswordController){
                                  return 'Password does not match';
                                }
                                return null;
                              },
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