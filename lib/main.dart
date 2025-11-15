import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Routers.dart';
import 'Service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Service().signOut(); // Đảm bảo đăng xuất trước khi thử đăng nhập lại
  await signIn();
  await testFirestoreConnection();
  runApp(const MyApp());
}

Future<void> signIn() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: "admin@gmail.com",
      password: "123456",
    );
    await FirebaseFirestore.instance.collection('information').doc(userCredential.user?.uid).set({
        'avatar':
            'https://res.cloudinary.com/dgfwcrbyg/image/upload/v1762953911/robot_logo_zsdlxk.png',
        'name': "admin",
        'email': "admin@gmail.com",
        'phonenumber': "0123456789",
        'birth': "01/01/1900",
        'sex': "Nam",
        'address': "TP.Hồ Chí Minh",
        "status":"offline",
        "loginat": DateTime.now(),
        "createdAt": DateTime.now(),
      },SetOptions(merge: true));
    print("✅ Kết nối bảng đăng nhập thành công!");
  } catch (e) {
    print("❌ Lỗi kết nối bảng đăng nhập, lỗi kết nối: $e");
    return;
  }
}

Future<void> testFirestoreConnection() async {
  try {
    await FirebaseFirestore.instance.collection('event').doc('ads5').set({
      'image1': '',
      'image2': '',
    });

    print("✅ Đã kết nối thành công Firestore!");
  } catch (e) {
    print("❌ Lỗi kết nối Firestore, lỗi kết nối: $e");
    return;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final router = Routers();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tungo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: Routers.initialization, // 👈 route khởi động đầu tiên
      routes: router.router_list, // 👈 danh sách các routes bạn khai báo
    );
  }
}
