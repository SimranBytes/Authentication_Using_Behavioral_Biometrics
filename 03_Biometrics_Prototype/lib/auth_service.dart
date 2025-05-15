import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constants.dart';

/// Service to handle Firebase Authentication and (optional) test auto-login.
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize Firebase. Call this once (e.g. in main) before using AuthService.
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  /// Signs in with email & password. Returns the [User] on success.
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    // For testing purposes, any credentials can auto-login when enabled.
    // if (AppConstants.enableTestAutoLogin) {
    //   // Uncomment below to bypass Firebase and auto-login anonymously:
    //   // await _auth.signInAnonymously();
    //   // return _auth.currentUser;
    // }

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Registers a new user with email & password. Returns the [User] on success.
  static Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Sends a password-reset email. Placeholder for now, not used in prototype.
  static Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Signs out the current user.
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns the currently signed-in [User], or null if none.
  static User? get currentUser => _auth.currentUser;
}