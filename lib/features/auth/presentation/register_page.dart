import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:studybuddy/features/auth/service/auth_service.dart';
import 'package:studybuddy/features/profile/model/user_model.dart';
import 'package:studybuddy/shared/widgets/custom_button.dart';
import 'package:studybuddy/shared/widgets/custom_textfield.dart'; // Idinagdag ito para sa link



  class RegisterPage extends StatefulWidget {
    const RegisterPage({super.key});

    @override
    State<RegisterPage> createState() => _RegisterPageState();
  }

  class _RegisterPageState extends State<RegisterPage> {
    final _formKey = GlobalKey<FormState>();
    final AuthService _authService = AuthService();
    final _usernameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmpasswordController = TextEditingController();
    String? _authError;


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

    Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      user? newUser = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (newUser != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Verify your Email'),
            content: Text(
              'A verification link has been sent to your email.\n\n'
              'Please verify your account before logging in.'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _authError = e.toString().replaceAll('Exception: ', '');
      });
    }
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
                                height: 25,
                              ),
                              // Full Name TextField
                              CustomTextfield(
                                controller: _usernameController,
                                hintText: 'Username',
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if(value == null || value.isEmpty){
                                    return 'Full Name is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              // Email TextField
                              CustomTextfield(
                                controller: _emailController,
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
                                height: 25,
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
                                height: 25,
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
                                  if(_passwordController.text.trim() != _confirmpasswordController.text.trim()){
                                    return 'Password does not match';
                                  }
                                  return null;
                                },
                              ),
                                SizedBox(
                                  height: 35,
                                ),
                                if(_authError != null ) ...[
                                  Text(_authError!,
                                  style: GoogleFonts.itim(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                              CustomButton(
                                text: 'Create Account',
                                backgroundColor: const Color(0xFFFD9519),
                                textColor: Colors.black,
                                fontSize: 30,
                                height: 57,
                                width: 255,
                                onTap: signUp,
                              ),
                              SizedBox(
                                height: 30,
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