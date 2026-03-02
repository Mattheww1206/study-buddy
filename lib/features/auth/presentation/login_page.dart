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
      await _authService.signInWithEmailOrUsername(
        emailOrUsername: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if(!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    
  } catch (e) {
    setState(() {
      _authError = e.toString();
    });
  } finally {
    if(mounted){
    setState(() {
      _isLoading = false;
    });
    }
  }
}

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _authError = null;
    });

    try {
      final gUser = await _authService.signInWithGoogle();

      if(gUser == null) return;

      if(!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      setState(() {
        _authError = e.toString().replaceFirst('Exception: ', '');
      });

    } finally {
      if(mounted) {
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
          title: Text('Reset Password',
          style: GoogleFonts.itim()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your email and we will send you the reset link.',
              style: GoogleFonts.itim(
                fontSize: 15
              ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              if(errorMessage != null)...[
                SizedBox(height: 8),
                Text(errorMessage!, 
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
              onPressed:() => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
            onPressed: () async {
              if(emailController.text.trim().isEmpty){
                setDialogState(() => errorMessage = 'Email is required',);
                return;
              }

              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                await _authService.resetPassword(email: emailController.text.trim());
                nav.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Password reset email has been sent! Please check your email.'))
                );
              } catch (e) {
                setDialogState(() {
                  errorMessage = e.toString().replaceFirst('Exception: ', '');
                });
              }
            },
            child: Text('Send', 
            style: GoogleFonts.itim(
              color: Colors.blueAccent,
            ),
            ),
            )
          ],
          ),
        )
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
                  height: 210,
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
                              height: 20,
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
                              height: 20,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showForgotPasswordDialog();
                                    },
                                    child: Text('Forgot Password?',
                                    style: GoogleFonts.itim(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                            height: 30,
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
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        thickness: 0.5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text('Or Sign In with',
                                      style: GoogleFonts.itim()
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        thickness: 0.5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              CustomButton(
                                text: 'Sign in With Google',
                                height: 55,
                                width: 250,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                borderColor: Colors.black,
                                borderWidth: 1,
                                fontSize: 18,
                                icon: Image.asset(
                                  'assets/google-icon.png',
                                  height: 35,
                                ),
                                onTap: () {
                                  signInWithGoogle();
                                },
                              ),
                             
                            SizedBox(
                              height: 30,
                            ),
                            Text('New to StudyBuddy?',
                            style: GoogleFonts.itim(
                              fontSize: 22,
                            ),
                            ),
                            CustomButton(
                              text: 'Create Account',
                              backgroundColor: const Color(0xFFFD9519),
                              textColor: Colors.black,
                              fontSize: 27,
                              height: 55,
                              width: 250,
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