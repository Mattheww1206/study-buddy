import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:studybuddy/features/auth/model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); 

  // sign up
  Future<AppUser?> signUp({
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

      final newUser = AppUser(
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


  Future<AppUser?> signIn({
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

      return AppUser(
        userId: credential.user!.uid,  
        username: data['username'],
        emailAdd: data['email'],          
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleLoginAuthError(e));
    }
  }

  Future<AppUser?> signInWithEmailOrUsername({
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
      rethrow;
    }
  }

  // sign out
  Future<void> signOut() async {
    final User? loggedUser = _auth.currentUser;

    if(loggedUser != null){
      final gUser = loggedUser.providerData.any((provider) => provider.providerId == 'google.com');

      if(gUser) {
        try {
          await _googleSignIn.signOut();
          await _googleSignIn.disconnect();
        } catch (_) {
         
        }
      }
    }
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
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
   // forgot password
   Future<void> resetPassword({
    required String email
   }) async {
    try {
      await _auth.sendPasswordResetEmail(email : email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleResetPasswordError(e));
    }
   }
   
   String _handleResetPasswordError(FirebaseAuthException e ){
    switch(e.code){
      case 'user-not-found':
        return 'No account has been found with this email.';
      case 'invalid-email':
        return 'Invalid email format';
      default:
        return 'Something went wrong. Please try again';  

    }
   }


     Future<AppUser?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      // oopen yung google account
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      // pag nag cancel si user
      if (gUser == null) return null;

      final GoogleSignInAuthentication gAuth =
          await gUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

       // checks kung yung google account na ginamit via google sign in is naka registered naba sa pag create ng account through Email/Password
      final emailCheck = await _firestore.collection('users')
                         .where('email', isEqualTo: gUser.email)
                         .limit(1)
                         .get();

      if (emailCheck.docs.isNotEmpty){
        final existingData = emailCheck.docs.first.data();
        final existingProvider = existingData['provider'] ?? 'password';

        if(existingProvider == 'password'){
          throw Exception('This email is already registered with a password. Please login with your Email and Password instead.');
        }
      }
      
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception('Google sign-in failed.');

      // checks kung existing na si user
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) {
        // new user is masisave na sa firebase
        final newUser = AppUser(
          userId: firebaseUser.uid,
          username: firebaseUser.displayName ?? 'user_${firebaseUser.uid.substring(0, 5)}',
          emailAdd: firebaseUser.email ?? '',
          provider: 'google',
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
        return newUser;
      }

      // pag existing user na nirereturn nalang yung data nila
      final data = doc.data() as Map<String, dynamic>;
      return AppUser(
        userId: firebaseUser.uid,
        username: data['username'],
        emailAdd: data['email'],
      );

    } catch (e) {
      if(e is FirebaseAuthException){
        throw Exception(_handleLoginAuthError(e));
      }
       rethrow;
    } 
     }

}