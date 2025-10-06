import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<bool> login_user(String username, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Mở cửa sổ đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // người dùng bấm hủy

      // Lấy token từ Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("❌ Lỗi đăng nhập Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String?> register_user(
    String name,
    String email,
    String phonenumber,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance.collection('information').doc(email).set({
        'name': name,
        'phonenumber': phonenumber,
        'timestamp': DateTime.now(),
      });
      return "";
    } catch (e) {
      return null;
    }
  }
}
