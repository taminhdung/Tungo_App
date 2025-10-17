import 'package:flutter/material.dart';
import '../Routers.dart';

class ForgotPassword1 extends StatefulWidget {
  const ForgotPassword1({super.key});
  State<ForgotPassword1> createState() => _ForgotPasswordState1();
}

class _ForgotPasswordState1 extends State<ForgotPassword1> {
  TextEditingController _username_value = TextEditingController();
  void move_page() {
    // Navigator.pushReplacementNamed(context, Routers.forgot_password1);
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      backgroundColor: Color.fromRGBO(245, 203, 88, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 150,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routers.login);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
          ),
        ),
        title: Text(
          "Quên mật khẩu",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: 412,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: 30, left: 30, right: 30),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Đã gửi mã về email của bạn",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Hãy kiểm tra email của bạn. Nếu không thấy thư, vui lòng kiểm tra mục thư rác.",
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 35),
                ],
              ),

              SizedBox(height: 300),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Quay về trang xác thực mã sau 10 giây."),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Routers.register);
                    },
                    child: Text(
                      "Tới luôn",
                      style: TextStyle(color: Color.fromRGBO(233, 83, 34, 1)),
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
