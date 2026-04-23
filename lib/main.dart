import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/core/ConnectivityProvider.dart';
import 'package:studybuddy/core/auth_wrapper.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/results/provider/result_provider.dart';
import 'package:studybuddy/features/theme/theme_data.dart';
import 'package:studybuddy/routes/all_routes.dart';
import 'package:studybuddy/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => ResultProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initialize() async {  
    try {
    await FirebaseService.initializeFirebase();

    } catch (e, stack) {
      debugPrint('Initialization error: $e');
      debugPrint('Stack trace: $stack');
    rethrow; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: defaultColor,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          // Still initializing — show splash
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
           return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          return const AuthWrapper();
        },
      ),
      routes: AllRoutes.routes,
    );
  }
}