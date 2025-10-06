import 'package:flutter/material.dart';
import '../Routers.dart';
class Login extends StatefulWidget {
  const Login({super.key});
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(252, 142, 106, 1),
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
            SizedBox(height: 15),
            Text(
              "Tiện lợi • Nhanh chóng • Giá rẻ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 45),
            SizedBox(
              width: 180, // 👈 chiều rộng
              height: 50, // 👈 chiều cao
              child: TextButton(
                onPressed: (){Navigator.pushReplacementNamed(context, Routers.login1);},
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    const Color.fromRGBO(245, 203, 88, 1),
                  ),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                child: const Text(
                  "Đăng nhập",
                  style: TextStyle(color: Color.fromRGBO(233, 83, 34, 1)),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 180, // 👈 chiều rộng
              height: 50, // 👈 chiều cao
              child: TextButton(
                onPressed: () {Navigator.pushReplacementNamed(context, Routers.register);},
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    const Color.fromRGBO(243, 233, 181, 1),
                  ),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                child: const Text(
                  "Đăng ký",
                  style: TextStyle(color: Color.fromRGBO(233, 83, 34, 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
