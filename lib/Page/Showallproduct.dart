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
      backgroundColor: Color.fromRGBO(245, 203, 88, 1),
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
          "Danh sách sản phẩm",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          print("Mới nhất clicker");
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 2,
                          ),
                          backgroundColor: Colors.red[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Mới nhất",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          print("Bán chạy clicker");
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 2,
                          ),
                          backgroundColor: Colors.red[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Bán chạy",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          print("Giảm giá clicker");
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 2,
                          ),
                          backgroundColor: Colors.red[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Giảm giá",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  GridView.builder(
                    shrinkWrap: true, // ⚡ Bắt buộc: tự co chiều cao
                    physics:
                        NeverScrollableScrollPhysics(), // ⚡ Vô hiệu cuộn riêng
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 15,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              // This ClipRRect was not properly closed.
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              child: a == true
                                  ? SizedBox(
                                      width: 80, // chiều ngang
                                      height: 80, // chiều dọc
                                      child: CircularProgressIndicator(
                                        strokeWidth: 10, // độ dày của vòng tròn
                                        color: Colors.black, // màu vòng tròn
                                      ),
                                    )
                                  : Image.network(
                                      "https://drive.google.com/uc?export=view&id=1vZvoXPtmtf0RtNdO7Nc8_akG3aOwa7e6",
                                      width: 130,
                                      height: 130,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 10),
                                          Text(
                                            "Cơm gà xối mỡ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),

                                          SizedBox(height: 5),
                                          Text(
                                            "đ50.000",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Colors.orange,
                                            ),
                                          ),

                                          SizedBox(height: 7),

                                          Text(
                                            "Giảm giá 20%",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),

                                          SizedBox(height: 8),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.grey,
                                                size: 14,
                                              ),
                                              SizedBox(width: 1),
                                              Text(
                                                "TP.Hồ Chí Minh",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(height: 74),

                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),

                                              SizedBox(height: 25),

                                              Text(
                                                "5.0",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 5),

                                          Text(
                                            "Đã bán 4.4k",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ), // This closing parenthesis was misplaced.
                      );
                    },
                  ),
                ],
              ),
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
