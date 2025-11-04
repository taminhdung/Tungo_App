import 'package:flutter/material.dart';
import '../Routers.dart';

class ForgotPassword3 extends StatefulWidget {
  const ForgotPassword3({super.key});
  State<ForgotPassword3> createState() => _ForgotPasswordState3();
}

class _ForgotPasswordState3 extends State<ForgotPassword3> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;

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
          "Đặt lại mật khẩu",
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
                  const Text(
                    "Đặt lại mật khẩu",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  const Text(
                    "Hãy đặt mật khẩu khác với mật khẩu trước đó để đảm bảo bảo mật cho tài khoản của bạn.",
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 35),
                  const Text(
                    "Mật khẩu mới",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      hintText: "Nhập mật khẩu mới",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 233, 181, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Nhập lại mật khẩu",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _confirmController,
                    obscureText: _hideConfirm,
                    decoration: InputDecoration(
                      hintText: "Nhập lại mật khẩu",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 233, 181, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hideConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _hideConfirm = !_hideConfirm;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),

              Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      if (_passwordController.text.isEmpty ||
                          _confirmController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vui lòng nhập đầy đủ thông tin"),
                          ),
                        );
                      } else if (_passwordController.text !=
                          _confirmController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Mật khẩu không trùng khớp"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đặt lại mật khẩu thành công!"),
                          ),
                        );
                        Navigator.pushReplacementNamed(context, Routers.login);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color.fromRGBO(233, 83, 34, 1),
                      ),
                    ),
                    child: const Text(
                      "Xác nhận",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 200),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Tôi cần sự hỗ trợ khác?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Routers.supports);
                    },
                    child: const Text(
                      "Trợ giúp",
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
