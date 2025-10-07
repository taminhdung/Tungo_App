import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Service {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<bool> login_user(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      await prefs.setString("login", "user");
      await prefs.setString("email", username);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    final prefs = await SharedPreferences.getInstance();
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
      final result = await _auth.signInWithCredential(credential);
      await prefs.setString("login", "google");
      await prefs.setString("name", result.user?.displayName ?? "");
      return result;
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
      await FirebaseFirestore.instance.collection('information').doc(email).set(
        {'name': name, 'phonenumber': phonenumber, 'timestamp': DateTime.now()},
      );
      return "";
    } catch (e) {
      return null;
    }
  }

  Future<String?> getname() async {
    final prefs = await SharedPreferences.getInstance();
    String name_value="";
    if (prefs.getString("login").toString() == "google") {
      final prefs = await SharedPreferences.getInstance();
      final name = await prefs
          .getString("name")
          .toString()
          .split(" ")[prefs.getString("name").toString().split(" ").length - 1];
      name_value=name;
    } else {
      final name= await FirebaseFirestore.instance.collection('information').doc(prefs.getString("email")).get();
      name_value=name.data()?['name'];
    }
    return name_value.split(" ")[name_value.split(" ").length-1];
  }
}
