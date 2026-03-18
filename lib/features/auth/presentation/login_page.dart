import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/auth/service/auth_service.dart';
import 'package:studybuddy/widgets/custom_button.dart';
import 'package:studybuddy/widgets/custom_textfield.dart';

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
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  // New Blue 60-30-10 Palette
  static const Color primaryColor = Color(0xFF1976D2);   // 60%
  static const Color secondaryColor = Color(0xFFE3F2FD); // 30%
  static const Color accentColor = Color(0xFF2196F3);    // 10%

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
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Changed to light for blue bg
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      final user = await _authService.signInWithEmailOrUsername(
        emailOrUsername: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      }

      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      final error = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        if (error.contains('No account found')) {
          _emailError = error;
          _passwordError = null;
        } else if (error.contains('verify your email')) {
          _emailError = error;
          _passwordError = null;
        } else if (error.contains('Incorrect email or password')) {
          _passwordError = 'Incorrect email or password.';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      final gUser = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (gUser != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(gUser);
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      setState(() {
        _emailError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    String? errorMessage;

    await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
                title: Text('Reset Password', style: GoogleFonts.itim()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter your email and we will send you the reset link.',
                      style: GoogleFonts.itim(fontSize: 15),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: GoogleFonts.itim(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      )
                    ]
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (emailController.text.trim().isEmpty) {
                        setDialogState(
                          () => errorMessage = 'Email is required',
                        );
                        return;
                      }

                      final nav = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        await _authService.resetPassword(
                            email: emailController.text.trim());
                        nav.pop();
                        messenger.showSnackBar(SnackBar(
                          content: const Text(
                              'Password reset email has been sent! Please check your email.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                      } catch (e) {
                        setDialogState(() {
                          errorMessage =
                              e.toString().replaceFirst('Exception: ', '');
                        });
                      }
                    },
                    child: Text(
                      'Send',
                      style: GoogleFonts.itim(
                        color: accentColor,
                      ),
                    ),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor, // Applied Primary (60%)
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/study.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Welcome!',
                style: GoogleFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Changed to White for contrast on blue
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Login to continue your study journey',
                style: GoogleFonts.itim(
                  color: Colors.black.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              // The White Card Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white, // Card acts as the Secondary surface (30%)
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
                          controller: _emailController,
                          hintText: 'Email or Username',
                          keyboardType: TextInputType.emailAddress,
                          fillColor: secondaryColor, // Applied Secondary (30%)
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email or Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextfield(
                          controller: _passwordController,
                          hintText: 'Password',
                          isPassword: true,
                          fillColor: secondaryColor, // Applied Secondary (30%)
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        if (_emailError != null || _passwordError != null) ...[
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 13),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _emailError ?? _passwordError!,
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => showForgotPasswordDialog(),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.itim(
                                color: accentColor, // Applied Accent (10%)
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          text: 'Login',
                          backgroundColor: primaryColor, // Applied Primary (60%)
                          textColor: Colors.white,
                          fontSize: 22,
                          width: 160,
                          height: 55,
                          isLoading: _isLoading,
                          onTap: () async {
                            await signIn();
                          },
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: Text(
                                'OR SIGN IN WITH',
                                style: GoogleFonts.itim(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'Sign in with Google',
                          height: 55,
                          width: double.infinity,
                          backgroundColor: Colors.white,
                          textColor: Colors.black87,
                          borderColor: accentColor.withValues(alpha: 0.3), // Lightened Accent
                          borderWidth: 1.5,
                          fontSize: 18,
                          icon: Image.asset(
                            'assets/google-icon.png',
                            height: 24,
                          ),
                          onTap: () {
                            signInWithGoogle();
                          },
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New to StudyBuddy? ',
                              style: GoogleFonts.itim(fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, 'register'),
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.itim(
                                  fontSize: 16,
                                  color: accentColor, // Applied Accent (10%)
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}