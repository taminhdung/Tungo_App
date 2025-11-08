import 'package:flutter/material.dart';
import '../Routers.dart';
import '../Service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});
  // ignore: annotate_overrides
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  static Service service = Service();
  TextEditingController _email_value = TextEditingController();
  void move_page() {
    Navigator.pushReplacementNamed(context, Routers.forgot_password);
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
            Navigator.pushReplacementNamed(context, Routers.login1);
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
                    "Đặt lại mật khẩu",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Chúng tôi sẽ cung cấp cho bạn 1 mật khẩu mới sau khi chúng tôi nhận được mã xác thực từ email của bạn.Hãy nhập email của bạn.",
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 35),
                  Text(
                    "Email",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _email_value,
                    decoration: InputDecoration(
                      hintText: "gmail@gmail.com",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 233, 181, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),

              SizedBox(
                width: 200,
                height: 50,
                child: TextButton(
                  onPressed: () async {
                    String? notification = await service.resetpassword(
                      _email_value.text,
                    );
                    if (notification != "") {
                      final snackBar = SnackBar(
                        content: Text("Email này chưa được đăng ký!"),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        Routers.forgot_password1,
                      );
                    }
                  },
                  child: Text(
                    "Gửi mã",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Color.fromRGBO(233, 83, 34, 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 300),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Tôi cần sự hỗ trợ khác?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Routers.supports);
                    },
                    child: Text(
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
