import 'package:flutter/material.dart';
import '../Routers.dart';

class Initialization extends StatefulWidget {
  const Initialization({super.key});
  State<Initialization> createState() => _Initializationstate();
}

class _Initializationstate extends State<Initialization>  with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, Routers.login);
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
              image: AssetImage("assets/images/logo_install.png"),
              width: 180,
              height: 180,
            ),
            SizedBox(height: 1),
            Image(
              image: AssetImage("assets/images/text.png"),
              width: 180,
              height: 90,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
