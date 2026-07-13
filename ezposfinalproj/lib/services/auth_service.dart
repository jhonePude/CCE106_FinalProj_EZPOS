import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED FOR FIRESTORE

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // ADDED

  User? get currentUser => _auth.currentUser;
  Stream<User?> get userStream => _auth.authStateChanges();

  // UPDATED: Now saves extra fields to Firestore
  Future<UserCredential?> signUp(String email, String password, String name, String phone) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password.trim(),
      );

      // Save user profile data to Firestore
      if (res.user != null) {
        await _firestore.collection('users').doc(res.user!.uid).set({
          'fullName': name,
          'contactNumber': phone,
          'email': email,
          'role': 'staff',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return res;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An error occurred during registration.";
    }
  }

  // LOGIN
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed.";
    }
  }

  // GOOGLE SIGN IN
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}