import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/profile/model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign up
  Future<appUser?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message: 'Username is already taken.'
        );
      }

      UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = appUser(
        userId: userCredential.user!.uid,
        username: username,
        emailAdd: email
      );
      
      await _firestore
       .collection('users')
       .doc(userCredential.user!.uid)
       .set(newUser.toMap());


      await userCredential.user!.sendEmailVerification();

      await _auth.signOut();

      return newUser;

    } on FirebaseAuthException catch (e) {
      throw Exception(_handleRegisterAuthError(e));
    } catch (e) {
      throw Exception('Unexpected error occurred.');
    }
  }

  String _handleRegisterAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'invalid-email':
        return 'Invalid email format.';
      default:
        return 'Something went wrong.';
    }
  }


  Future<appUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
  
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = credential.user;

      if(firebaseUser == null){
        throw Exception('User not found after login.');
      } 

      await firebaseUser.reload();
      firebaseUser = _auth.currentUser;

      if(!firebaseUser!.emailVerified){
        await _auth.signOut();
        throw Exception('Please verify your email before logging in.');
      }

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User record is not found.');
      }

      final data = doc.data() as Map<String, dynamic>;

      return appUser(
        userId: credential.user!.uid,  
        username: data['username'],
        emailAdd: data['email'],          
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleLoginAuthError(e));
    }
  }

  Future<appUser?> signInWithEmailOrUsername({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      String email = emailOrUsername;

      // Check if the input is a username
      if (!emailOrUsername.contains('@')) {
        final query = await _firestore
            .collection('users')
            .where('username', isEqualTo: emailOrUsername)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw Exception('No account found with this username.');
        }

        email = query.docs.first['email'];
      }

      return await signIn(email: email, password: password);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }


  // error messages
  String _handleLoginAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}