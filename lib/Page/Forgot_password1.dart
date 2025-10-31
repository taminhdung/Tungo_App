import 'package:flutter/material.dart';
import '../Routers.dart';
import 'dart:async';

class ForgotPassword1 extends StatefulWidget {
  const ForgotPassword1({super.key});
  State<ForgotPassword1> createState() => _ForgotPasswordState1();
}

class _ForgotPasswordState1 extends State<ForgotPassword1> {
  TextEditingController _username_value = TextEditingController();
  int countdown = 10;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
        Navigator.pushReplacementNamed(context, Routers.forgot_password2);
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      backgroundColor: Color.fromRGBO(245, 203, 88, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 120,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routers.login);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Quên mật khẩu",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Đã gửi mã về email của bạn",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              Image.asset("assets/images/gmail.png", height: 60),
              SizedBox(height: 40),

              Text(
                "Hãy kiểm tra email của bạn. Nếu không thấy thư, vui lòng kiểm tra mục thư rác.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Quay về trang xác thực mã sau $countdown giây.",
                    style: TextStyle(fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        Routers.forgot_password2,
                      );
                    },
                    child: Text(
                      "Tới luôn",
                      style: TextStyle(
                        color: Color.fromRGBO(233, 83, 34, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
