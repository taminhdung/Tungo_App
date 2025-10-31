import 'package:flutter/material.dart';
import '../Routers.dart';

class Me extends StatelessWidget {
  const Me({super.key});

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
                backgroundImage: NetworkImage(
                  "https://drive.google.com/uc?export=view&id=1gWQ6jZdroDcjBPS8rbw8fSqw5zyDx7Mu",
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Dũng Họ Cao",
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
              Text(
                "nguyenminhduong525@gmail.com",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 30),
              MenuItem(
                icon: Icons.shopping_bag_outlined,
                title: "Đơn hàng của tôi",
                onTap: () {
                  print("Đơn hàng của tôi");
                },
              ),
              MenuItem(
                icon: Icons.person_outlined,
                title: "Địa chỉ giao hàng",
                onTap: () {
                  print("Địa chỉ giao hàng");
                },
              ),
              MenuItem(
                icon: Icons.credit_card_outlined,
                title: "Phương thức thanh toán",
                onTap: () {
                  print("Phương thức thanh toán");
                },
              ),
              // MenuItem(
              //   icon: Icons.headset_mic_outlined,
              //   title: "Liên hệ với chúng tôi",
              //   onTap: () {
              //     print("Liên hệ với chúng tôi");
              //   },
              // ),
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
                icon: Icons.logout,
                title: "Đăng xuất",
                onTap: () {
                  print("Đăng xuất");
                },
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

  const MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
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
