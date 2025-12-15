import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInWithGoogle {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// 🔐 Sign in with Google (Firebase Auth)
  /// Returns Firebase [User] on success, null on cancel
  Future<User?> signIn() async {
    try {
      // 1️⃣ Trigger Google Sign-In UI
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled sign-in
        return null;
      }

      // 2️⃣ Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3️⃣ Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4️⃣ Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  /// 🚪 Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// 👤 Current user
  User? get currentUser => _auth.currentUser;
}
