import 'package:flutter/material.dart';
import '../Routers.dart';

class Voucher extends StatefulWidget {
  const Voucher({super.key});
  State<Voucher> createState() => _VoucherState();
}

class _VoucherState extends State<Voucher> {
  final a = false;
  void move_page() {
    Navigator.pushReplacementNamed(context, Routers.home);
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 1,
          backgroundColor: Colors.red,
          onTap: (index) {
            switch (index) {
              case 0:
                move_page();
                break;
              case 1:
                null;
                break;
              case 2:
                null;
                break;
              case 3:
                null;
                break;
              case 4:
                null;
                break;
            }
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Trang chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.discount_outlined),
              activeIcon: Icon(Icons.discount),
              label: "Mã giảm giá",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: "Yêu thích",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              activeIcon: Icon(Icons.notifications),
              label: "Thông báo",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              activeIcon: Icon(Icons.person),
              label: "Tôi",
            ),
          ],
        ),
      ),
    ));
  }
}
