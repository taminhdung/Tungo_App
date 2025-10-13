import 'package:flutter/material.dart';
import '../Routers.dart';

class Showallproduct extends StatefulWidget {
  const Showallproduct({super.key});
  State<Showallproduct> createState() => _ShowallproductState();
}

class _ShowallproductState extends State<Showallproduct> {
  final a = false;
  void move_page() {
    Navigator.pushReplacementNamed(context, Routers.home);
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 150,
        leading: IconButton(
          onPressed: move_page,
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
          ),
        ),
        title: Text(
          "Tất cả sản phẩm",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: 412,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 10,
            ),
            child: GridView.builder(
              shrinkWrap: true, // ⚡ Bắt buộc: tự co chiều cao
              physics: NeverScrollableScrollPhysics(), // ⚡ Vô hiệu cuộn riêng
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                childAspectRatio: 2.33,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadiusGeometry.all(
                              Radius.circular(20),
                            ), // bo góc nếu muốn
                            child: a == true
                                ? Padding(
                                    padding: EdgeInsetsGeometry.only(
                                      top: 1,
                                      bottom: 5,
                                      left: 30,
                                      right: 30,
                                    ),
                                    child: SizedBox(
                                      width: 120, // chiều ngang
                                      height: 120, // chiều dọc
                                      child: CircularProgressIndicator(
                                        strokeWidth: 10, // độ dày của vòng tròn
                                        color: Colors.black, // màu vòng tròn
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    "https://drive.google.com/uc?export=view&id=1vZvoXPtmtf0RtNdO7Nc8_akG3aOwa7e6",
                                    width: 100,
                                    height: 150,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.only(left: 10),
                            child: Row(
                              children: [
                                Text("Cơm gà xối mỡ"),
                                Text("₫35.000"),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text("Giảm giá"),
                              Row(children: [Icon(Icons.star), Text("sao")]),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
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
    ));
  }
}
