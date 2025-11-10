import 'package:flutter/material.dart';
import '../Routers.dart';
import '../Service.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>  with WidgetsBindingObserver{
  final service = Service();
  bool _hidden_password = true;
  bool _hidden_password1 = true;
  bool _flag_the_terms = false;
  bool _isbutton=true;
  void open_the_terms() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Điều khoản", textAlign: TextAlign.center),
        backgroundColor: Colors.grey[200],
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text("""Điều khoản về việc mua hàng và tạo tài khoản
1. Tạo tài khoản
- Khi đăng ký tài khoản trên ứng dụng, bạn đồng ý cung cấp thông tin chính xác và đầy đủ.
- Bạn chịu trách nhiệm bảo mật thông tin đăng nhập của mình.
- Mọi hoạt động thực hiện bằng tài khoản của bạn sẽ được coi là do bạn thực hiện.

2. Mua hàng
- Tất cả các giao dịch mua hàng phải tuân theo quy định và giá cả hiển thị trên ứng dụng.
- Sau khi xác nhận thanh toán, đơn hàng sẽ được xử lý và giao đến địa chỉ bạn cung cấp.
- Trong trường hợp hủy đơn hàng hoặc trả hàng, vui lòng tham khảo chính sách hủy/trả hàng của ứng dụng.
- Mọi tranh chấp về giao dịch sẽ được giải quyết theo quy định của pháp luật.

3. Quyền và nghĩa vụ
- Người dùng có quyền từ chối mua hàng, yêu cầu hủy đơn hoặc đổi trả hàng hóa theo chính sách của ứng dụng.
- Người dùng không được sử dụng thông tin sai lệch, gian lận hoặc thực hiện hành vi làm ảnh hưởng đến hệ thống.

4. Bảo mật thông tin
- Chúng tôi cam kết bảo mật thông tin cá nhân và chỉ sử dụng cho mục đích quản lý tài khoản và giao dịch.
"""),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => {
                  setState(() {
                    _flag_the_terms = false;
                  }),
                  Navigator.pop(context),
                },
                child: Text(
                  "Không đồng ý",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Color.fromRGBO(233, 83, 34, 1),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => {
                  setState(() {
                    _flag_the_terms = true;
                  }),
                  Navigator.pop(context),
                },
                child: Text("Đồng ý", style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Color.fromRGBO(233, 83, 34, 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextEditingController _name_value = TextEditingController();
  TextEditingController _email_value = TextEditingController();
  TextEditingController _phonenumber_value = TextEditingController();
  TextEditingController _password_value = TextEditingController();
  TextEditingController _passwordagain_value = TextEditingController();
  Future<void> register() async {
    _isbutton=false;
    String name = _name_value.text;
    String email = _email_value.text;
    String phonenumber = _phonenumber_value.text;
    String password = _password_value.text;
    String passwordagain = _passwordagain_value.text;
    if (!RegExp(r'^\S+(?:\s+\S+){1,}$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tên phải ít nhất 2 từ"),
          backgroundColor: Colors.red,
        ),
      );
      _isbutton=true;
      return null;
    }
    if (!RegExp(
      r'^[A-Za-z][A-Za-z0-9._-]+@[A-Za-z]+\.(com)$',
    ).hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email không hợp lệ."),
          backgroundColor: Colors.red,
        ),
      );
      _isbutton=true;
      return null;
    }
    if (!RegExp(r'^(?:\+84|84|0)(3|5|7|8|9)[0-9]{8}$').hasMatch(phonenumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Số điện thoại không hợp lệ."),
          backgroundColor: Colors.red,
        ),
      );
      _isbutton=true;
      return null;
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*])[A-Za-z\d!@#\$%^&*]{6,}$',
    ).hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Mật khẩu bao gồm 1 kí tự đặc biệt, 1 chữ hoa, 1 chữ thường và có độ dài 6 ký tự không có dấu.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      _isbutton=true;
      return null;
    }
    if (!_flag_the_terms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Vui lòng đọc điều khoản",
          ),
          backgroundColor: Colors.red,
        ),
      );
      _isbutton=true;
      return null;
    }
    if (password == passwordagain) {
      String? resurt = await service.register_user(
        name,
        email,
        phonenumber,
        password,
      );
      if (resurt != null) {
        _isbutton=true;
        Navigator.pushReplacementNamed(context, Routers.login1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đăng kí thất bại, vui lòng kiểm tra lại."),
            backgroundColor: Colors.red,
          ),
        );
        _isbutton=true;
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mật khẩu và mật khẩu nhập lại không trùng khớp."),
          backgroundColor: Colors.red,
        ),
      );
      _isbutton=true;
      return null;
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
          "Đăng ký",
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
                    "Họ và tên",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _name_value,
                    decoration: InputDecoration(
                      hintText: "Nguyễn văn a",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 233, 181, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Email",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _email_value,
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
                  SizedBox(height: 15),
                  Text(
                    "Số điện thoại",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _phonenumber_value,
                    decoration: InputDecoration(
                      hintText: "0999999999",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 233, 181, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
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
                  SizedBox(height: 15),
                  Text(
                    "Nhập lại Mật khẩu",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _passwordagain_value,
                    obscureText: _hidden_password1,
                    obscuringCharacter: "•",
                    decoration: InputDecoration(
                      hintText: _hidden_password1 ? "•••••••••" : "123456789",
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
                            _hidden_password1 =
                                !_hidden_password1; // đổi trạng thái khi bấm
                          });
                        },
                        icon: Icon(
                          _hidden_password1
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color.fromRGBO(233, 83, 34, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Để tiếp tục đăng kí, vui lòng đọc "),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // bỏ padding mặc định
                          minimumSize: Size(0, 0), // bỏ kích thước tối thiểu
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // thu nhỏ vùng bấm
                        ),
                        onPressed: open_the_terms,
                        child: Text(
                          "điều khoản",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(233, 83, 34, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 50,
                child: TextButton(
                  onPressed: _isbutton?register:null,
                  child: Text(
                    "Đăng ký",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Color.fromRGBO(233, 83, 34, 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Đã có tài khoản?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Routers.login1);
                    },
                    child: Text(
                      "Đăng nhập",
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
