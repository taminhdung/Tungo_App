import 'package:flutter/material.dart';
import '../Routers.dart';
import '../Service.dart';

class Login1 extends StatefulWidget {
  const Login1({super.key});
  State<Login1> createState() => _Login1State();
}

class _Login1State extends State<Login1> {
  bool _hidden_password = true;
  bool _isbutton=true;
  TextEditingController _username_value = TextEditingController();
  TextEditingController _password_value = TextEditingController();
  Service service = Service();
  void login() async {
    _isbutton=false;
    String username = _username_value.text;
    String password = _password_value.text;
    bool flag_login = await service.login_user(username, password);
    if (flag_login) {
      _isbutton=true;
      Navigator.pushReplacementNamed(context, Routers.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sai mật khẩu hoặc tài khoản."),
          backgroundColor: Colors.red,
        ),
      );
      _isbutton=true;
    }
  }

  void login_google() async {
    final resurt = await service.signInWithGoogle();
    if (resurt != null) {
      Navigator.pushReplacementNamed(context, Routers.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập thất bại."),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          "Đăng nhập",
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
                    "Chào mừng",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Hãy đăng nhập vào ứng dụng để có thể trải nghiệm mua hàng và nhận nhiều ưu đãi một cách thuận lợi từ Tungo nhé.",
                  ),
                  SizedBox(height: 35),
                  Text(
                    "Email",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _username_value,
                    decoration: InputDecoration(
                      hintText: "gmail@gmail.com",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 233, 181, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    "Mật khẩu",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _password_value,
                    obscureText: _hidden_password,
                    obscuringCharacter: "•",
                    decoration: InputDecoration(
                      hintText: _hidden_password ? "•••••••••" : "123456789",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 233, 181, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidden_password =
                                !_hidden_password; // đổi trạng thái khi bấm
                          });
                        },
                        icon: Icon(
                          _hidden_password
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color.fromRGBO(233, 83, 34, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        Routers.forgot_password,
                      );
                    },
                    child: Text(
                      "Quên mật khẩu",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(233, 83, 34, 1),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: TextButton(
                  onPressed: _isbutton?login:null,
                  child: Text(
                    "Đăng nhập",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Color.fromRGBO(233, 83, 34, 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text("Hoặc đăng nhập với"),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Color.fromRGBO(255, 222, 207, 1),
                    child: InkWell(
                      onTap: () {
                        login_google();
                      },
                      child: Image.asset(
                        "assets/images/google.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Chưa có tài khoản?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Routers.register);
                    },
                    child: Text(
                      "Đăng kí",
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
