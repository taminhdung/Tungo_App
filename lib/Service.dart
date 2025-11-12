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
      await prefs.setString("type_login", "user");
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
                "id": data['id'],
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
                "id": data['id'],
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
      await prefs.setString("type_login", "google");
      // Đăng nhập Firebase
      final result = await _auth.signInWithCredential(credential);
      final docSnap = await FirebaseFirestore.instance
          .collection("information")
          .doc(result.user?.uid)
          .get();
      if (!docSnap.exists) {
        await FirebaseFirestore.instance
            .collection('information')
            .doc(result.user?.uid)
            .set({
              'avatar': result.user?.photoURL,
              'name': result.user?.displayName,
              'email': result.user?.email,
              'phonenumber': result.user?.phoneNumber,
              'birth': "1900-01-01",
              'sex': "",
              'address': "",
              'timestamp': DateTime.now(),
            });
      }
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
                "id": data['id'],
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
                "id": data['id'],
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
            'https://res.cloudinary.com/dgfwcrbyg/image/upload/v1762953911/robot_logo_zsdlxk.png',
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
    String mota,
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
            'mota': mota,
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
    String mota,
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
        'mota': mota,
        'useruid': prefs.getString('uid'),
      }, SetOptions(merge: true));
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

  Future<bool> update_user(
    anh,
    ten,
    sodienthoai,
    ngaysinh,
    gioitinh,
    diachi,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await FirebaseFirestore.instance
          .collection('information')
          .doc(prefs.getString('uid'))
          .set({
            'avatar': anh,
            'name': ten,
            'phonenumber': sodienthoai,
            'birth': ngaysinh,
            'sex': gioitinh,
            'address': diachi,
          }, SetOptions(merge: true));
      print('✅ Sửa thông tin thành công.');
      return true;
    } catch (e) {
      print('❌ Sửa thông tin thất bại: $e');
      return false;
    }
  }

  Future<bool> add_order(id, anh, tensanpham, gia, soluong) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      int soluong1 = 0;
      final docRef = FirebaseFirestore.instance
          .collection('order')
          .doc(prefs.getString('uid'))
          .collection('orders')
          .doc(id);

      final docSnap = await docRef.get();
      if (docSnap.exists) {
        final data = docSnap.data() as Map<String, dynamic>;
        print(data);
        soluong1 = int.tryParse(data['soluong']?.toString() ?? '0') ?? 0;
      }
      int add = soluong is int
          ? soluong
          : int.tryParse(soluong?.toString() ?? '') ?? 0;
      await FirebaseFirestore.instance
          .collection('order')
          .doc(prefs.getString('uid'))
          .collection("orders")
          .doc(id)
          .set({
            'id': id.toString(),
            'anh': anh.toString(),
            'ten': tensanpham.toString(),
            'gia': gia.toString(),
            'soluong': (soluong1 + add).toString(),
            'useruid': prefs.getString('uid').toString(),
          });
      print('✅ Thêm giỏ hàng thành công.');
      return true;
    } catch (e) {
      print('❌ Thêm giỏ hàng thất bại: $e');
      return false;
    }
  }

  Future<List?> get_order() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await FirebaseFirestore.instance
        .collection('order')
        .doc(prefs.getString('uid'))
        .collection("orders")
        .get();
    if (result.docs.isEmpty) {
      return [];
    } else {
      final data = result.docs.map((doc) => doc.data()).toList();
      return data;
    }
  }

  Future<void> delete_order(list_remove_item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listremove = list_remove_item as List<String>;
    for (int i = 0; i < listremove.length; i++) {
      final result = await FirebaseFirestore.instance
          .collection('order')
          .doc(prefs.getString('uid'))
          .collection("orders")
          .doc(listremove[i])
          .delete();
    }
  }

  Future<String?> add_order_pay(list_item) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String name_order_pay = "";
      int count_item = 0;
      Map<String, Map<String, String>> list_item1 = list_item;
      // Lấy danh sách documents trong "orders"
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('order_pay')
          .doc(prefs.getString('uid'))
          .collection("orders")
          .get();

      // Kiểm tra có document nào không
      if (snapshot.docs.isNotEmpty) {
        count_item = snapshot.docs.length;
      }

      // Duyệt từng item trong list_item1 để thêm vào order{count_item}
      for (int i = 0; i < list_item1.length; i++) {
        name_order_pay =
            name_order_pay +
            (list_item1['item${i.toString()}']?['ten']).toString() +
            ", ";
        final orderDocRef = FirebaseFirestore.instance
            .collection('order_pay')
            .doc(prefs.getString('uid'))
            .collection("orders")
            .doc('order$count_item');

        // ✅ đảm bảo document order{count_item} có tồn tại
        await orderDocRef.set({
          "createdAt": FieldValue.serverTimestamp(),
          "status": "Đang tạo đơn", // bạn có thể đổi tên field này
        }, SetOptions(merge: true));
        // ✅ thêm item vào subcollection bên trong
        await orderDocRef
            .collection(count_item.toString())
            .doc(i.toString())
            .set({
              "id": list_item1['item${i.toString()}']?['id'].toString(),
              "anh": list_item1['item${i.toString()}']?['anh'].toString(),
              "ten": list_item1['item${i.toString()}']?['ten'].toString(),
              "gia": list_item1['item${i.toString()}']?['gia'].toString(),
              "soluong": list_item1['item${i.toString()}']?['soluong']
                  .toString(),
            });
        prefs.setString('order_id', count_item.toString());
      }
      await FirebaseFirestore.instance
          .collection('order_pay')
          .doc(prefs.getString('uid'))
          .collection("orders")
          .doc('order$count_item')
          .set({
            "nameorder": name_order_pay.substring(
              0,
              name_order_pay.length - 2,
            ), // bạn có thể đổi tên field này
          }, SetOptions(merge: true));
      return "";
    } catch (e) {
      print("❌ Lỗi khi thêm đơn thanh toán: $e");
      return "Thêm vào đơn thanh toán thất bại. Lỗi: $e";
    }
  }

  Future<List?> get_order_pay() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await FirebaseFirestore.instance
        .collection('order_pay')
        .doc(prefs.getString('uid'))
        .collection("orders")
        .doc('order${prefs.getString('order_id')}')
        .collection(prefs.getString('order_id').toString())
        .get();
    if (result.docs.isEmpty) {
      return [];
    } else {
      final data = result.docs.map((doc) => doc.data()).toList();
      return data;
    }
  }

  Future<List?> get_order_pay1() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await FirebaseFirestore.instance
        .collection('order_pay')
        .doc(prefs.getString('uid'))
        .collection("orders")
        .get();
    if (result.docs.isEmpty) {
      return [];
    } else {
      final data = result.docs.map((doc) => doc.data()).toList();
      return data;
    }
  }

  Future<void> add_order_food(Map<String, String> list_order_food) async {
    int count = 0;
    final prefs = await SharedPreferences.getInstance();
    await FirebaseFirestore.instance
        .collection("order_pay")
        .doc(prefs.getString('uid'))
        .collection("orders")
        .doc('order${prefs.getString('order_id')}')
        .set({
          "trigia": list_order_food["trigia"],
          "method_pay": list_order_food["method_pay"],
          "totalorder": list_order_food["totalorder"],
          "status": "Chưa thanh toán",
        }, SetOptions(merge: true));
    if (list_order_food["id"] != "") {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('voucher_users')
          .doc(prefs.getString('uid'))
          .collection("vouchers")
          .get();
      if (!snapshot.docs.isEmpty) {
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['id'] ==
              (int.parse(list_order_food['id'].toString())).toString()) {
            print(int.parse(data['soluong']) - 1);
            await FirebaseFirestore.instance
                .collection('voucher_users')
                .doc(prefs.getString('uid'))
                .collection("vouchers")
                .doc('item${(int.parse(data['id']) + 1).toString()}')
                .set({
                  "soluong": (int.parse(data['soluong']) - 1).toString(),
                }, SetOptions(merge: true));
          }
        }
      }
    }
  }

  Future<void> delete_order_food() async {
    final prefs = await SharedPreferences.getInstance();
    await FirebaseFirestore.instance
        .collection("order_pay")
        .doc(prefs.getString('uid'))
        .collection("orders")
        .doc('order${prefs.getString('order_id')}')
        .delete();
  }

  Future<void> verifyOldPasswordAndChange(
    String email,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("Không có người dùng đăng nhập!");
        return;
      }

      // Tạo credential từ email + mật khẩu cũ
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      // Xác thực lại người dùng (kiểm tra mật khẩu cũ)
      await user.reauthenticateWithCredential(credential);
      // Nếu xác thực thành công, cập nhật mật khẩu mới
      await user.updatePassword(newPassword);
      print("🔒 Đổi mật khẩu mới thành công!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        print("❌ Mật khẩu cũ không đúng!");
      } else if (e.code == 'user-mismatch') {
        print("❌ Email không khớp với tài khoản hiện tại!");
      } else {
        print("⚠️ Lỗi khác: ${e.message}");
      }
    }
  }
}
