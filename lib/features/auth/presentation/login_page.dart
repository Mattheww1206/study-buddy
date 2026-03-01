  import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/features/auth/service/auth_service.dart';
import 'package:studybuddy/shared/widgets/custom_button.dart';
import 'package:studybuddy/shared/widgets/custom_textfield.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _authError;
  bool _isLoading = false;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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


  Future<void> signIn() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _authError = null;
  });

  try {
    final loggedInUser = await _authService.signInWithEmailOrUsername(
      emailOrUsername: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    await FirebaseAuth.instance.currentUser?.reload();  
    if (loggedInUser != null) {
     // automatic na ma detect ni auth wrapper yung login 
     // and ma d-direct na sa Nav
      if (mounted) {
        Navigator.of(context).pop(); // <-- this pops the LoginPage
      }

      // authStateChanges() should trigger and AuthWrapper navigates
      print('Login successful, user: ${FirebaseAuth.instance.currentUser?.email}');
    }
  } catch (e) {
    setState(() {
      _authError = e.toString();
    });
  } finally {
    setState(() {
      _isLoading = false;
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
                  width: 330,
                  height: 220,
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
                              height: 25,
                            ),
                            // Email TextField
                            CustomTextfield(
                              controller: _emailController,
                              hintText: 'Email or Username',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if(value == null || value.isEmpty) {
                                  return 'Email or Username is required';
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
                                if(value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                             SizedBox(
                              height: 50,
                            ),
                              CustomButton(
                                text: 'Login',
                                backgroundColor: Color(0xFF16056B),
                                textColor: Colors.white,
                                fontSize: 23,
                                width: 140,
                                height: 50,
                                isLoading: _isLoading,
                                onTap: () async {
                                  await signIn();
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
                            CustomButton(
                              text: 'Create Account',
                              backgroundColor: const Color(0xFFFD9519),
                              textColor: Colors.black,
                              fontSize: 28,
                              height: 55,
                              width: 260,
                              onTap: () {
                                Navigator.pushNamed(context, 'register');
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