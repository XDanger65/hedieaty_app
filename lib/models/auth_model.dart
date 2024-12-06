import 'package:firebase_auth/firebase_auth.dart';

class AuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login method
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Returns the User instance
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Sign-up method
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Returns the User instance
    } catch (e) {
      print('Sign-up error: $e');
      return null;
    }
  }

  // Sign-out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out successfully.");
    } catch (e) {
      print('Sign-out error: $e');
    }
  }

  // Get the currently logged-in user
  User? get currentUser => _auth.currentUser;
}
