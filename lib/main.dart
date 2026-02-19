import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Add this import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. INITIALIZE FIRST (Essential!)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. NOW you can talk to Firestore
  try {
    await FirebaseFirestore.instance.collection('connection_test').add({
      'status': 'StudyBuddy is Online!!!!!',
      'time': DateTime.now().toString(),
    });
    print("Data sent to Firestore successfully!");
  } catch (e) {
    print("Error sending to Firestore: $e");
  }

  print("Firebase initialized successfully for: ${Firebase.app().options.projectId}");

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Firebase Connected!')),
      ),
    );
  }
}