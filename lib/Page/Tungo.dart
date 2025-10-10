import 'package:flutter/material.dart';
import '../Routers.dart';

class Tungo extends StatefulWidget {
  const Tungo({super.key});
  State<Tungo> createState() => _Tungostate();
}

class _Tungostate extends State<Tungo> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      // Navigator.pushReplacementNamed(context, Routers.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(245, 203, 88, 1),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage("assets/images/robot_logo.png"),
              width: 180,
              height: 180,
            ),
            SizedBox(height: 1),
          ],
        ),
      ),
    );
  }
}
