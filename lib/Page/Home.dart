import 'package:flutter/material.dart';
import '../Service.dart';
class Home extends StatefulWidget {
  const Home({super.key});
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final service=Service();
  String name = "";
  void initState() {
    super.initState();
    loadName();
  }

  void loadName() async {
    final n = await service.getname();
    setState(() {
      name = n ?? "";
    });
  }
  @override
  Widget build(Object context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 80,
        title: InkWell(
          onTap: () {
            print("a");
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo_install.png", width: 40),
              SizedBox(height: 5),
              Image.asset("assets/images/text.png", width: 40),
            ],
          ),
        ),
        actions: [
          SizedBox(
            height: 40,
            width: 251,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Áo khoác lông cừu nam",
                hintStyle: TextStyle(color: Colors.red[200]),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                suffixIcon: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.search, color: Colors.red),
                ),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: null,
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.red),
            ),
          ),
          SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: null,
              icon: Icon(Icons.message_outlined, color: Colors.red),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: 1000,
          decoration: BoxDecoration(color: Color.fromRGBO(245, 203, 88, 1)),
          child: Wrap(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.only(
                  left: 30,
                  right: 30,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, $name',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Hãy thưởng thức món ăn cùng Tungo nào",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 643,
                width: 412,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          backgroundColor: Colors.red,
          onTap: null,
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
              label: "Mã giải giá",
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
    );
  }
}
