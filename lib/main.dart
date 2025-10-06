import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Routers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await signIn();
  await testFirestoreConnection();
  runApp(const MyApp());
}

Future<void> signIn() async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: "admin@gmail.com",
      password: "123456",
    );
    print("✅ Kết nối bảng đăng nhập thành công!");
  } catch (e) {
    print("❌ Lỗi kết nối bảng đăng nhập, lỗi kết nối: $e");
  }
}
Future<void> testFirestoreConnection() async {
  try {
    await FirebaseFirestore.instance.collection('Note').doc('Content').set({
      'name': 'Tungo',
      'timestamp': DateTime.now(),
    });

    print("✅ Đã kết nối thành công Firestore!");
  } catch (e) {
    print("❌ Lỗi kết nối Firestore, lỗi kết nối: $e");
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final router=Routers();
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