import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Service {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> login_user(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    int count = 1;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: username, password: password);
      await prefs.setString("uid", userCredential.user!.uid);
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('voucher')
          .get();
      List<Map<String, dynamic>> vouchers = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      for (var data in vouchers) {
        await FirebaseFirestore.instance
            .collection('voucher_users')
            .doc('${userCredential.user?.uid}')
            .collection('vouchers')
            .doc('item${count.toString()}')
            .set({
              'anh': data['anh'],
              'ten': data['ten'],
              'soluong': data['soluong'],
              'dieukien': data['dieukien'],
              'mota': data['mota'],
              'hieuluc': data['hieuluc'],
            }, SetOptions(merge: true));
        if (count != vouchers.length) {
          count++;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    final prefs = await SharedPreferences.getInstance();
    int count = 1;
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
      await FirebaseFirestore.instance
          .collection('information')
          .doc(result.user?.uid)
          .set({
            'name': result.user?.displayName,
            'email': result.user?.email,
            'phonenumber': result.user?.phoneNumber,
            'avatar': result.user?.photoURL,
            'timestamp': DateTime.now(),
          });
      await prefs.setString("uid", result.user!.uid);
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('voucher')
          .get();
      List<Map<String, dynamic>> vouchers = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      for (var data in vouchers) {
        await FirebaseFirestore.instance
            .collection('voucher_users')
            .doc('${result.user?.uid}')
            .collection('vouchers')
            .doc('item${count.toString()}')
            .set({
              'anh': data['anh'],
              'ten': data['ten'],
              'soluong': data['soluong'],
              'dieukien': data['dieukien'],
              'mota': data['mota'],
              'hieuluc': data['hieuluc'],
            }, SetOptions(merge: true));
        if (count != vouchers.length) {
          count++;
        }
      }
      return result;
    } catch (e) {
      print("❌ Lỗi đăng nhập Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await SharedPreferences.getInstance().then((prefs) => prefs.remove("uid"));
  }

  Future<String?> register_user(
    String name,
    String email,
    String phonenumber,
    String password,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('information').doc(uid).set({
        'name': name,
        'email': email,
        'phonenumber': phonenumber,
        'avatar': '',
        'timestamp': DateTime.now(),
      });
      return "";
    } catch (e) {
      return null;
    }
  }

  Future<String?> getname() async {
    final prefs = await SharedPreferences.getInstance();
    String name_value = "";
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('information')
        .doc(prefs.getString("uid"))
        .get();
    name_value = doc.get('name');
    return name_value;
  }

  Future<List?> getevent() async {
    final result = await FirebaseFirestore.instance.collection('event').get();

    if (result.docs.isEmpty) {
      return [];
    } else {
      final data = result.docs.map((doc) => doc.data()).toList();
      return data;
    }
  }

  Future<List?> getlist() async {
    final result = await FirebaseFirestore.instance.collection('product').get();
    if (result.docs.isEmpty) {
      return [];
    } else {
      final data = result.docs.map((doc) => doc.data()).toList();
      return data;
    }
  }

  Future<List?> getVoucherList() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await FirebaseFirestore.instance
        .collection('voucher_users')
        .doc(prefs.getString("uid"))
        .collection('vouchers')
        .get();
    if (snapshot.docs.isEmpty) {
      return [];
    } else {
      final data = snapshot.docs.map((doc) => doc.data()).toList();
      return data;
    }
  }
}
