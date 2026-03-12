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

  final Color _themeBackgroundColor = const Color(0xFFFAEEFF);

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
        statusBarIconBrightness: Brightness.dark,
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
                        messenger.showSnackBar(const SnackBar(
                            content: Text(
                                'Password reset email has been sent! Please check your email.')));
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
                        color: Colors.blueAccent,
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
      backgroundColor: _themeBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Inalis ang malaking top padding para tumaas ang layout
              const SizedBox(height: 10),
              
              Center(
                child: Image.asset(
                  'assets/study.png',
                  width: 180, // Bahagyang linuitan para mas compact
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              
              // Inalis ang SizedBox dito para magkalapit ang Logo at Welcome
              Text(
                'Welcome!',
                style: GoogleFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 4), // Maliit na space para sa subtitle
              
              Text(
                'Login to continue your study journey',
                style: GoogleFonts.itim(
                  color: Colors.black.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 15), // Space bago ang card
              
              // The White Card Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          fillColor: _themeBackgroundColor,
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
                          errorText: _passwordError,
                          isPassword: true,
                          fillColor: _themeBackgroundColor,
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => showForgotPasswordDialog(),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.itim(
                                color: const Color(0xFF4A449A),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          text: 'Login',
                          backgroundColor: const Color(0xFF5D54D0),
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
                          borderColor: Colors.grey.shade300,
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
                                  color: Colors.orange.shade800,
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