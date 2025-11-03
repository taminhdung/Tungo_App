import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // Bắt buộc nếu chạy main async
  WidgetsFlutterBinding.ensureInitialized(); // nếu chạy trong Flutter
  await Firebase.initializeApp();

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Voucher')
      .get();

  List<Map<String, dynamic>> vouchers = snapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();

  print("Vouchers:");
  for (var voucher in vouchers) {
    print(voucher);
  }
}
