import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:studybuddy/features/auth/service/auth_service.dart';
import 'package:studybuddy/features/auth/model/user_model.dart';
import 'package:studybuddy/widgets/custom_button.dart';
import 'package:studybuddy/widgets/custom_textfield.dart';

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

  // Background color constant para parehas sa textfields
  final Color _themeBackgroundColor = const Color(0xFFFAEEFF);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      AppUser? newUser = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (newUser != null) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Verify your Email'),
            content: const Text(
                'A verification link has been sent to your email.\n\n'
                'Please verify your account before logging in.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
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
      backgroundColor: _themeBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              
              // Fox Logo Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow.withOpacity(0.3), // Glow effect
                  ),
                  child: Image.asset(
                    'assets/studybuddy-logo.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
      
              const SizedBox(height: 15),
      
              // Welcome Texts
              Text(
                'Join StudyBuddy!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Create your free account today',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
      
              const SizedBox(height: 30),
      
              // Main White Container (The Card)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Username
                        CustomTextfield(
                          controller: _usernameController,
                          hintText: 'Username',
                          keyboardType: TextInputType.name,
                          fillColor: _themeBackgroundColor, // Applied Color
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
      
                        // Email
                        CustomTextfield(
                          controller: _emailController,
                          hintText: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          fillColor: _themeBackgroundColor, // Applied Color
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email Address is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid Email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
      
                        // Password
                        CustomTextfield(
                          controller: _passwordController,
                          hintText: 'Password',
                          isPassword: true,
                          fillColor: _themeBackgroundColor, // Applied Color
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must contain at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
      
                        // Confirm Password
                        CustomTextfield(
                          controller: _confirmpasswordController,
                          hintText: 'Confirm Password',
                          isPassword: true,
                          fillColor: _themeBackgroundColor, // Applied Color
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm Password is required';
                            }
                            if (_passwordController.text.trim() !=
                                _confirmpasswordController.text.trim()) {
                              return 'Password does not match';
                            }
                            return null;
                          },
                        ),
      
                        const SizedBox(height: 30),
      
                        if (_authError != null) ...[
                          Text(
                            _authError!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.itim(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
      
                        // Create Account Button (Orange)
                        CustomButton(
                          text: 'Create Account →',
                          backgroundColor: const Color(0xFFF27E2B),
                          textColor: Colors.white,
                          fontSize: 20,
                          height: 60,
                          width: double.infinity,
                          onTap: signUp,
                        ),
      
                        const SizedBox(height: 25),
      
                        // Login Link
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.itim(
                              fontSize: 16,
                              color: const Color(0xFF3B338B),
                            ),
                            children: [
                              const TextSpan(
                                  text: 'Already studying with us? '),
                              TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  color: Color(0xFF5D59D1),
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
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}