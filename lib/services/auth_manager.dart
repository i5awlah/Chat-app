
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getIdForCurrentUser() {
    if (_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    } else {
      return null;
    }
  }

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        return result.user!.uid;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<String?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        return result.user!.uid;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

// Future resetPassword(String email) async {
//   try {
//     return await _auth.sendPasswordResetEmail(email: email);
//   } catch (e) {
//     print(e.toString());
//   }
// }
}

