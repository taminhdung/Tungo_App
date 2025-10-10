import 'package:flutter/material.dart';
import '../Service.dart';
import '../Routers.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final service = Service();
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

  void move_page() {
    Navigator.pushReplacementNamed(context, Routers.tungo);
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 80,
        title: InkWell(
          onTap: move_page,
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
                hintText: "Cơm gà xối mỡ",
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
      body: Container(
        width: 1000,
        decoration: BoxDecoration(color: Color.fromRGBO(245, 203, 88, 1)),
        child: Wrap(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(left: 30, right: 30, bottom: 20),
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
              padding: EdgeInsets.only(top: 20),
              height: 644,
              width: 412,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: null,
                          icon: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(243, 233, 181, 1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                                child: Icon(
                                  Icons.ramen_dining_outlined,
                                  color: Color.fromRGBO(233, 83, 34, 1),
                                  size: 40,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Bữa ăn \nchính",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: null,
                          icon: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(243, 233, 181, 1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                                child: Icon(
                                  Icons.fastfood_outlined,
                                  color: Color.fromRGBO(233, 83, 34, 1),
                                  size: 35,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Đồ ăn \nnhanh",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: null,
                          icon: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(243, 233, 181, 1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                                child: Icon(
                                  Icons.icecream_outlined,
                                  color: Color.fromRGBO(233, 83, 34, 1),
                                  size: 40,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Món tráng \nmiệng",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: null,
                          icon: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(243, 233, 181, 1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                                child: Icon(
                                  Icons.emoji_food_beverage_outlined,
                                  color: Color.fromRGBO(233, 83, 34, 1),
                                  size: 40,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Món đồ \nuống",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(
                      color: Color.fromRGBO(255, 216, 199, 1), // màu của đường
                      thickness: 1, // độ dày
                      indent: 1, // lề trái
                      endIndent: 1, // lề phải
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Phổ biến",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 23,
                          ),
                        ),
                        IconButton(
                          onPressed: null,
                          icon: Row(
                            children: [
                              Text(
                                "Xem tất cả",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromRGBO(233, 83, 34, 1),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right_outlined,
                                color: Color.fromRGBO(233, 83, 34, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true, // ⚡ Bắt buộc: tự co chiều cao
                      physics:
                          NeverScrollableScrollPhysics(), // ⚡ Vô hiệu cuộn riêng
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromRGBO(233, 83, 34, 1),
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        "https://daotaobeptruong.vn/wp-content/uploads/2021/02/ban-com-chien-duong-chau.jpg",
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "-50%",
                                            style: TextStyle(
                                              color: Colors.red,
                                              backgroundColor: Colors.red[50],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.only(
                                    top: 4,
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Cơm chiên dương châu quán ăn Thành Pháp siêu ngon và rẻ",
                                        maxLines: 2, // chỉ hiển thị 1 dòng
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            width: 70,
                                            height: 23,
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                            ),
                                            child: Text(
                                              "Giảm giá",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            width: 50,
                                            height: 23,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.amber,
                                              ),
                                              color: Colors.yellow[100],
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 18,
                                                  color: Colors.amber,
                                                ),
                                                SizedBox(width: 2),
                                                Transform.translate(
                                                  offset: Offset(
                                                    0,
                                                    -1.5,
                                                  ), // 👈 di chuyển lên trên 2 pixel
                                                  child: Text(
                                                    "5.0",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "₫",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              Text(
                                                "30.000",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Đã bán",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                "4.4K",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.place_outlined,
                                            size: 15,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "TP.Hồ Chí Minh",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 13),
                    Container(
                      height: 130,
                      width: 370,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadiusGeometry.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ), // bo góc nếu muốn
                            child: Image.network(
                              "https://copilot.microsoft.com/th/id/BCO.6cfcbae0-5bb9-4671-9581-82f734ba7653.png",
                              width: 185,
                              height: 130,
                              fit: BoxFit.cover, // cắt ảnh để vừa khung
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadiusGeometry.only(
                              bottomRight: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.network(
                              "https://copilot.microsoft.com/th/id/BCO.81487675-622b-49ab-a6eb-003979e2838c.png",
                              width: 185,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
