import 'package:flutter/material.dart';
import '../Routers.dart';

class Supports extends StatefulWidget {
  const Supports({super.key});
  State<Supports> createState() => _SupportsState();
}

class _SupportsState extends State<Supports> {
  void move_page() {
    Navigator.pushReplacementNamed(context, Routers.supports);
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold());
  }
}
