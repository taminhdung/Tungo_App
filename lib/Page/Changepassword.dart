// lib/Page/Changepassword.dart
import 'package:flutter/material.dart';
import '../Routers.dart';
import '../Service.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});
  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword>
    with WidgetsBindingObserver {
  static Service service = Service();

  bool _isbutton = true;

  // Controllers cho 3 ô mật khẩu
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // trạng thái hiển thị mật khẩu
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void move_page() {
    Navigator.pushReplacementNamed(context, Routers.forgot_password);
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Hàm kiểm tra đơn giản trước khi gọi API
  void _onSubmit() async {
    if (!_isbutton) return;
    setState(() {
      _isbutton = false;
    });

    final oldPwd = _oldController.text.trim();
    final newPwd = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (oldPwd.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin.')),
      );
      setState(() => _isbutton = true);
      return;
    }

    if (newPwd != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới và xác nhận không khớp.')),
      );
      setState(() => _isbutton = true);
      return;
    }

    // TODO: gọi API đổi mật khẩu ở đây nếu có service.changePassword(...)
    // Hiện tạm thông báo thành công và về home (hoặc màn trước)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công.')));

    setState(() => _isbutton = true);

    // chuyển về Home (hoặc thay route tuỳ bạn)
    Navigator.pushReplacementNamed(context, Routers.home);
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool obscure,
    VoidCallback? onEye,
  }) {
    // màu nền vàng nhạt giống ảnh
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color.fromRGBO(250, 247, 231, 1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        onPressed: onEye,
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: const Color.fromRGBO(233, 83, 34, 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // màu chủ đạo
    const primaryYellow = Color.fromRGBO(245, 203, 88, 1);
    const primaryOrange = Color.fromRGBO(233, 83, 34, 1);

    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        toolbarHeight: 150,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routers.login1);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryOrange),
        ),
        // Tiêu đề trên appbar giống mock
        title: const Text(
          "Đổi mật khẩu",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        // phần trắng bo cong ở phía dưới
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 28, left: 22, right: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bỏ phần tiêu đề "Đặt Lại Mật Khẩu" và mô tả theo yêu cầu
              // Thay vào đó chỉ hiển thị 3 input theo yêu cầu
              const SizedBox(height: 4),

              const Text(
                'Mật khẩu cũ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _oldController,
                obscureText: _obscureOld,
                decoration: _inputDecoration(
                  hint: 'Nhập mật khẩu cũ',
                  obscure: _obscureOld,
                  onEye: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Mật khẩu mới',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newController,
                obscureText: _obscureNew,
                decoration: _inputDecoration(
                  hint: 'Nhập mật khẩu mới',
                  obscure: _obscureNew,
                  onEye: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Nhập lại mật khẩu mới',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: _inputDecoration(
                  hint: 'Nhập lại mật khẩu mới',
                  obscure: _obscureConfirm,
                  onEye: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),

              const SizedBox(height: 30),

              // Nút Đặt Lại giữa màn hình như mock
              Center(
                child: SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isbutton ? _onSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Đặt Lại',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
