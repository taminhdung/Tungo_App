import 'package:flutter/material.dart';
import '../Routers.dart';
import '../Service.dart';

class Me extends StatefulWidget {
  const Me({super.key});
  @override
  State<Me> createState() => _MeState();
}

class _MeState extends State<Me> {
  static Service service = Service();
  Map<String, dynamic>? info;
  @override
  void initState() {
    super.initState();
    loadinformation();
  }

  Future<void> loadinformation() async {
    final data = await service.getinformation() as Map<String, dynamic>?;
    setState(() {
      info = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color.fromRGBO(233, 83, 34, 1),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    (info != null &&
                        info!['avatar'] != null &&
                        info!['avatar'].toString().isNotEmpty)
                    ? NetworkImage(info!['avatar'])
                    : null,
              ),
              info == null
                  ? Text(
                      "Ẩn danh",
                      style: TextStyle(color: Colors.white70, fontSize: 20),
                    )
                  : Text(
                      info!['name'],
                      style: TextStyle(color: Colors.white70, fontSize: 20),
                    ),
              info == null
                  ? Text(
                      "Ẩn danh",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    )
                  : Text(
                      info!['email'],
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
              SizedBox(height: 30),
              MenuItem(
                icon: Icons.person_outline,
                title: "Thông tin cá nhân",
                onTap: () {
                  print("Thông tin cá nhân");
                },
              ),
              MenuItem(
                icon: Icons.password_outlined,
                title: "Đổi mật khẩu",
                onTap: () {
                  print("Đổi mật khẩu");
                },
              ),
              MenuItem(
                icon: Icons.money_off_csred_sharp,
                title: "Đơn hàng",
                onTap: () {
                  print("Đơn hàng");
                },
              ),

              MenuItem(
                icon: Icons.help_outline,
                title: "Liên hệ với chúng tôi",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, Routers.supports);
                },
              ),
              MenuItem(
                icon: Icons.settings_outlined,
                title: "Cài đặt",
                onTap: () {
                  print("Cài đặt");
                },
              ),
              MenuItem(
                icon: Icons.no_accounts_outlined,
                title: "Xoá tài khoản",
                onTap: () {
                  print("Xoá tài khoản");
                },
              ),
              SizedBox(height: 181),
              MenuItem(
                icon: Icons.logout,
                title: "Đăng xuất",
                onTap: () {
                  service.signOut();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, Routers.login);
                },
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Color.fromRGBO(233, 83, 34, 1),
                size: 24,
              ),
            ),
            SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
