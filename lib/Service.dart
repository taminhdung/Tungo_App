import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

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
            'avatar': result.user?.photoURL,
            'name': result.user?.displayName,
            'email': result.user?.email,
            'phonenumber': result.user?.phoneNumber,
            'birth': "01/01/1990",
            'sex': "",
            'address': "",
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
        'avatar':
            'https://res.cloudinary.com/dgfwcrbyg/image/upload/v1762352719/image3_tsdwq3.png',
        'name': name,
        'email': email,
        'phonenumber': phonenumber,
        'birth': "01/01/1990",
        'sex': "",
        'address': "",
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

  Future<String?> uploadImagefood(File _image_path) async {
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
      print('✅ Tải ảnh lên thành công.');
      return data['secure_url'];
    } else {
      print('❌ Tải ảnh lên thất bại: ${response.statusCode}');
      return "";
    }
  }

  Future<String?> DeleteImagefood(String _image_link) async {
    final link;
    if (_image_link.contains("Flutter/Food/")) {
      link =
          'Flutter/Food/${_image_link.split("/")[(_image_link.split("/").length) - 1].split(".")[0]}';
    } else {
      link = _image_link
          .split("/")[(_image_link.split("/").length) - 1]
          .split(".")[0];
    }
    final cloudName = 'dgfwcrbyg';
    final uploadPreset = 'Upload_unsigned';
    final apiKey = '659899424938116';
    final apiSecret = 'NGQ28HG0Ae5k_sc27KiH5QBv2n0';
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final signatureSource = 'public_id=$link&timestamp=$timestamp$apiSecret';
    final signature = crypto.sha1
        .convert(utf8.encode(signatureSource))
        .toString();
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dgfwcrbyg/image/destroy',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['public_id'] = link
      ..fields['timestamp'] = timestamp
      ..fields['api_key'] = apiKey
      ..fields['signature'] = signature;
    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      print('✅ Xoá ảnh thành công.');
      return data['secure_url'];
    } else {
      print('❌ Xoá ảnh thất bại: ${response.statusCode}');
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
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('food')
          .get();
      await FirebaseFirestore.instance
          .collection('food')
          .doc('item${snapshot.docs.length}')
          .set({
            'id': snapshot.docs.length.toString(),
            'anh': anh,
            'ten': ten,
            'gia': gia,
            'tensukien': tensukien,
            'giamgia': giamgia,
            'type': type,
            'diachi': diachi,
            'sao': "0.0",
            'sohangdaban': "0",
            'useruid': prefs.getString('uid'),
          });
      print('✅ Thêm đồ ăn thành công.');
      return true;
    } catch (e) {
      print('❌ Thêm đồ ăn thất bại: $e');
      return false;
    }
  }

  Future<bool> update_food(
    String id,
    String anh,
    String ten,
    String gia,
    String tensukien,
    String giamgia,
    String type,
    String diachi,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await FirebaseFirestore.instance.collection('food').doc('item${id}').set({
        'anh': anh,
        'ten': ten,
        'gia': gia,
        'tensukien': tensukien,
        'giamgia': giamgia,
        'type': type,
        'diachi': diachi,
        'useruid': prefs.getString('uid'),
      },SetOptions(merge: true));
      print('✅ Sửa đồ ăn thành công.');
      return true;
    } catch (e) {
      print('❌ Sửa đồ ăn thất bại: $e');
      return false;
    }
  }

  Future<bool> delete_food(String id) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await FirebaseFirestore.instance
          .collection('food')
          .doc('item${id}')
          .delete();
      print('✅ Xoá đồ ăn thành công.');
      return true;
    } catch (e) {
      print('❌ Xoá đồ ăn thất bại: $e');
      return false;
    }
  }

  Future<String?> uploadImageuser(File _image_path) async {
    final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    final cloudName = 'dgfwcrbyg';
    final uploadPreset = 'Upload_unsigned';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dgfwcrbyg/image/upload',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] =
          'Flutter/Avatar' // thư mục
      ..fields['public_id'] =
          'image_${uniqueId}' // tên ảnh bạn muốn đặt
      ..files.add(await http.MultipartFile.fromPath('file', _image_path.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      print('✅ Tải ảnh lên thành công.');
      return data['secure_url'];
    } else {
      print('❌ Tải ảnh lên thất bại: ${response.statusCode}');
      return "";
    }
  }

  Future<String?> DeleteImageuser(String _image_link) async {
    final link;
    if (_image_link.contains("Flutter/Avatar/")) {
      link =
          'Flutter/Avatar/${_image_link.split("/")[(_image_link.split("/").length) - 1].split(".")[0]}';
    } else {
      link = _image_link
          .split("/")[(_image_link.split("/").length) - 1]
          .split(".")[0];
    }
    final cloudName = 'dgfwcrbyg';
    final uploadPreset = 'Upload_unsigned';
    final apiKey = '659899424938116';
    final apiSecret = 'NGQ28HG0Ae5k_sc27KiH5QBv2n0';
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final signatureSource = 'public_id=$link&timestamp=$timestamp$apiSecret';
    final signature = crypto.sha1
        .convert(utf8.encode(signatureSource))
        .toString();
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dgfwcrbyg/image/destroy',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['public_id'] = link
      ..fields['timestamp'] = timestamp
      ..fields['api_key'] = apiKey
      ..fields['signature'] = signature;
    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      print('✅ Xoá ảnh thành công.');
      return data['secure_url'];
    } else {
      print('❌ Xoá ảnh thất bại: ${response.statusCode}');
      return "";
    }
  }

  Future<bool> update_user(anh,ten,sodienthoai,ngaysinh,gioitinh,diachi) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await FirebaseFirestore.instance.collection('information').doc(prefs.getString('uid')).set({
        'avatar': anh,
        'name': ten,
        'phonenumber': sodienthoai,
        'birth': ngaysinh,
        'sex': gioitinh,
        'address': diachi,
      },SetOptions(merge: true));
      print('✅ Sửa thông tin thành công.');
      return true;
    } catch (e) {
      print('❌ Sửa thông tin thất bại: $e');
      return false;
    }
  }
}
