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
  bool _isLoading = false;

  // Blue 60-30-10 Palette
  static const Color primaryColor = Color(0xFF1976D2);   // 60%
  static const Color secondaryColor = Color(0xFFE3F2FD); // 30%
  static const Color accentColor = Color(0xFF2196F3);    // 10%

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Light icons for dark bg
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _authError = null;
    });

    try {
      AppUser? newUser = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (!mounted) return;

      if (newUser != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Verify your Email', style: GoogleFonts.itim()),
            content: Text(
                'A verification link has been sent to your email.\n\nPlease verify your account before logging in.',
                style: GoogleFonts.itim()),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor, // Applied Primary (60%)
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'assets/study.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Join StudyBuddy!',
                style: GoogleFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // White text for primary bg
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create your free account today',
                style: GoogleFonts.itim(
                  fontSize: 16,
                  color: Colors.black.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 15),
              // The White Card Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextfield(
                          controller: _usernameController,
                          hintText: 'Username',
                          keyboardType: TextInputType.name,
                          fillColor: secondaryColor, // Applied Secondary (30%)
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Username is required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        CustomTextfield(
                          controller: _emailController,
                          hintText: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          fillColor: secondaryColor, // Applied Secondary (30%)
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email Address is required';
                            }
                            if (!value.contains('@')) return 'Enter a valid Email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextfield(
                          controller: _passwordController,
                          hintText: 'Password',
                          isPassword: true,
                          fillColor: secondaryColor, // Applied Secondary (30%)
                          validator: (value) => (value == null || value.length < 8)
                              ? 'At least 8 characters required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        CustomTextfield(
                          controller: _confirmpasswordController,
                          hintText: 'Confirm Password',
                          isPassword: true,
                          fillColor: secondaryColor, // Applied Secondary (30%)
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm Password is required';
                            }
                            if (_passwordController.text !=
                                _confirmpasswordController.text) {
                              return 'Passwords do not match';
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
                                color: Colors.red, fontSize: 14),
                          ),
                          const SizedBox(height: 15),
                        ],
                        CustomButton(
                          text: 'Create Account',
                          backgroundColor: accentColor, // Applied Accent (10%)
                          textColor: Colors.white,
                          fontSize: 20,
                          height: 55,
                          width: double.infinity,
                          isLoading: _isLoading,
                          onTap: signUp,
                        ),
                        const SizedBox(height: 25),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.itim(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            children: [
                              const TextSpan(text: 'Already studying with us? '),
                              TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  color: primaryColor, // Used primary for link
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}