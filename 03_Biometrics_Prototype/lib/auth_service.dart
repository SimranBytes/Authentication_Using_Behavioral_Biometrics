import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // adjust your package path
import 'constants.dart';

class AuthService {
  AuthService._();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Must be called once in main() before any other auth operations.
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Sign in with email/password or, if override is enabled, anonymously.
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    if (AppConstants.enableTestAutoLogin) {
      final cred = await _auth.signInAnonymously();
      return cred.user;
    }
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Sign up with email/password or, if override is enabled, anonymously.
  static Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    if (AppConstants.enableTestAutoLogin) {
      final cred = await _auth.signInAnonymously();
      return cred.user;
    }
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Sign out the current user.
  static Future<void> signOut() => _auth.signOut();

  /// Returns the currently signed-in [User], or null if none.
  static User? get currentUser => _auth.currentUser;
}
