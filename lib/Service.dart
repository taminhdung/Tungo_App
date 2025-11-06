import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      var doc = await FirebaseFirestore.instance
          .collection('voucher_users')
          .doc(
            userCredential.user!.uid.toString(),
          ) // Thay bằng ID document bạn thấy trên console
          .get();
      print(doc.exists);
      print(userCredential.user!.uid.toString());
      if (doc.exists) {
        for (var data in vouchers) {
          await FirebaseFirestore.instance
              .collection('voucher_users')
              .doc('${userCredential.user!.uid.toString()}')
              .set({'createdAt': DateTime.now()}, SetOptions(merge: true));
          await FirebaseFirestore.instance
              .collection('voucher_users')
              .doc('${userCredential.user!.uid.toString()}')
              .collection('vouchers')
              .doc('item${count.toString()}')
              .set({
                'anh': data['anh'],
                'ten': data['ten'],
                'dieukien': data['dieukien'],
                'mota': data['mota'],
                'hieuluc': data['hieuluc'],
              }, SetOptions(merge: true));
          if (count != vouchers.length) {
            count++;
          }
        }
      } else {
        for (var data in vouchers) {
          await FirebaseFirestore.instance
              .collection('voucher_users')
              .doc('${userCredential.user!.uid.toString()}')
              .set({'createdAt': DateTime.now()}, SetOptions(merge: true));
          await FirebaseFirestore.instance
              .collection('voucher_users')
              .doc('${userCredential.user!.uid.toString()}')
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
      var doc = await FirebaseFirestore.instance
          .collection('voucher_users')
          .doc(
            result.user?.uid.toString(),
          ) // Thay bằng ID document bạn thấy trên console
          .get();
      print(doc.exists);
      print(result.user?.uid.toString());
      if (doc.exists) {
        for (var data in vouchers) {
          await FirebaseFirestore.instance
              .collection('voucher_users')
              .doc('${result.user?.uid.toString()}')
              .set({'createdAt': DateTime.now()}, SetOptions(merge: true));
          await FirebaseFirestore.instance
              .collection('voucher_users')
              .doc('${result.user?.uid.toString()}')
              .collection('vouchers')
              .doc('item${count.toString()}')
              .set({
                'anh': data['anh'],
                'ten': data['ten'],
                'dieukien': data['dieukien'],
                'mota': data['mota'],
                'hieuluc': data['hieuluc'],
              }, SetOptions(merge: true));
          if (count != vouchers.length) {
            count++;
          }
        }
      } else {
        for (var data in vouchers) {
          await FirebaseFirestore.instance
              .collection('voucher_users')
              .doc('${result.user?.uid.toString()}')
              .set({'createdAt': DateTime.now()}, SetOptions(merge: true));
          await FirebaseFirestore.instance
              .collection('voucher_users')
              .doc('${result.user?.uid.toString()}')
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
        'avatar':
            'https://res.cloudinary.com/dgfwcrbyg/image/upload/v1762352719/image3_tsdwq3.png',
        'timestamp': DateTime.now(),
      });
      return "";
    } catch (e) {
      return null;
    }
  }

  Future<Object?> getinformation() async {
    final prefs = await SharedPreferences.getInstance();
    String name_value = "";
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('information')
        .doc(prefs.getString("uid"))
        .get();
    return doc.data();
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
    final result = await FirebaseFirestore.instance.collection('food').get();
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

  Future<String?> resetpassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return "";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "Tài khoản chưa đăng ký!";
      } else {
        print('Lỗi: ${e.code}');
      }
    }
  }

  Future<File?> getImage() async {
    File? _image;
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      return _image;
    } else {
      return null;
    }
  }

  Future<String?> uploadImage(File _image_path) async {
    final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    final cloudName = 'dgfwcrbyg';
    final uploadPreset = 'Upload_unsigned';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dgfwcrbyg/image/upload',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] =
          'Flutter/Food' // thư mục
      ..fields['public_id'] =
          'image_${uniqueId}' // tên ảnh bạn muốn đặt
      ..files.add(await http.MultipartFile.fromPath('file', _image_path.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      print('✅ Upload thành công.');
      return data['secure_url'];
    } else {
      print('❌ Upload thất bại: ${response.statusCode}');
      return "";
    }
  }

  Future<bool> add_food(
    String anh,
    String ten,
    String gia,
    String tensukien,
    String giamgia,
    String type,
    String diachi,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try{
      QuerySnapshot snapshot=await FirebaseFirestore.instance
          .collection('food')
          .get();
      await FirebaseFirestore.instance
          .collection('food')
          .doc('item${snapshot.docs.length}').set({
            'anh':anh,
            'ten':ten,
            'gia':gia,
            'tensukien':tensukien,
            'giamgia':giamgia,
            'type':type,
            'diachi':diachi,
            'sao':"",
            'sohangdaban':"",
            'useruid': prefs.getString('uid')
          });
      return true;
    } catch (e){
      return false;
    }
  }
}