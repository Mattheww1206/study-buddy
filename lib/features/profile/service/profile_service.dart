
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPhoto({
    required String userId,
    required File imageFile,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);

    await _firestore
          .collection('users')
          .doc(userId)
          .update({'photoUrl': base64String});


    return base64String;
  }


  Future<void> updateUsername({
    required String userId,
    required String username,
  }) async {
    if (username.trim().isEmpty) return;
    await _firestore
          .collection('users')
          .doc(userId)
          .update({'username': username.trim()});
  }
}