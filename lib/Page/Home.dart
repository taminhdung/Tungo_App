import 'package:flutter/material.dart';
import '../Service.dart';
import '../Routers.dart';
import '../model/product_show.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'Me.dart';
import 'ProductDetail.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final service = Service();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int count_temp = 1;
  double posX = 300;
  double posY = 500;
  String name = "";
  int index_event = 2;
  Map<String, dynamic> item = {};
  Map<String, dynamic> event = {};
  Map<String, dynamic> name_event = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    load();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (count_temp < 2) {
        setState(() {
          count_temp++;
          index_event = count_temp;
        });
        change_index_event(index_event);
        print(count_temp);
      } else {
        timer.cancel();
        return;
      }
    });
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        index_event++;
        if (index_event >= 5) {
          index_event = 0;
        }
        change_index_event(index_event);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void load() async {
    await loadName();
    await get_Event();
    await get_Item();
  }

  Future<void> loadName() async {
    Map<String, dynamic>? data =
        await service.getinformation() as Map<String, dynamic>?;
    setState(() {
      name = data!['name'] ?? "Ẩn danh";
    });
  }

  void open_page_me() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void move_page(String path) {
    Navigator.pushReplacementNamed(context, path);
  }

  Future<void> get_Event() async {
    final result = await service.getevent();
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_event = {};
    for (int i = 0; i < data.length; i++) {
      map_event["ads$i"] = data[i];
    }
    setState(() {
      event = map_event;
    });
  }

  Future<void> get_Item() async {
    final result = await service.getlist();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_item = {};
    for (int i = 0; i < data.length - 1; i++) {
      map_item["item$i"] = data[i];
    }
    setState(() {
      item = map_item;
    });
  }

  void change_index_event(index) {
    setState(() {
      index_event = index;
      name_event["ads${index_event}"] = Map.from(event["ads${index_event}"]);
      print(name_event["ads${index_event}"]);
    });
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Me(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap: null,
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
        child: Stack(
          children: [
            Wrap(
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
                          color: Color.fromRGBO(
                            255,
                            216,
                            199,
                            1,
                          ), // màu của đường
                          thickness: 1, // độ dày
                          indent: 1, // lề trái
                          endIndent: 1, // lề phải
                        ),
                        SizedBox(height: 1),
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
                              onPressed: () =>
                                  move_page(Routers.showallproduct),
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 5,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            if (item["item$index"] == null) {
                              return SizedBox();
                            }
                            final products = ProductShow.fromJson(
                              item["item${index}"],
                            );
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetail(product: products),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(1),
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
                                child: Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color.fromRGBO(
                                              233,
                                              83,
                                              34,
                                              1,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            products.anh.isEmpty
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 5,
                                                      bottom: 5,
                                                      left: 30,
                                                      right: 30,
                                                    ),
                                                    child: SizedBox(
                                                      width: 110, // chiều ngang
                                                      height: 110, // chiều dọc
                                                      child: CircularProgressIndicator(
                                                        strokeWidth:
                                                            10, // độ dày của vòng tròn
                                                        color: Colors
                                                            .black, // màu vòng tròn
                                                      ),
                                                    ),
                                                  )
                                                : Image.network(
                                                    //ảnh
                                                    products.anh,
                                                    width: 180,
                                                    height: 120,
                                                    fit: BoxFit.fill,
                                                  ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  //giam gia
                                                  "-${products.giamgia}%",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    backgroundColor:
                                                        Colors.red[50],
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              //ten
                                              products.ten,
                                              maxLines:
                                                  1, // chỉ hiển thị 1 dòng
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
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
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(5),
                                                        ),
                                                  ),
                                                  child: Text(
                                                    //ten su kien
                                                    "${products.tensukien}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 30),
                                                Container(
                                                  padding: EdgeInsets.all(2),
                                                  width: 50,
                                                  height: 23,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.amber,
                                                    ),
                                                    color: Colors.yellow[100],
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(5),
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
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
                                                          //sao
                                                          '${products.sao}',
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                      //gia
                                                      NumberFormat.decimalPattern(
                                                        'vi',
                                                      ).format(
                                                        (int.parse(
                                                          "${int.parse(products.gia) - ((int.parse(products.gia) * int.parse(products.giamgia)) ~/ 100)}",
                                                        )),
                                                      ),
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
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      //sohangban
                                                      products.sohangdaban,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
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
                                                  //dia chi
                                                  products.diachi,
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
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 13),
                        Container(
                          height: 130,
                          width: 370,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadiusGeometry.only(
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ), // bo góc nếu muốn
                                child: name_event["ads${index_event}"] == null
                                    ? Padding(
                                        padding: EdgeInsetsGeometry.only(
                                          top: 5,
                                          bottom: 5,
                                          left: 30,
                                          right: 30,
                                        ),
                                        child: SizedBox(
                                          width: 120, // chiều ngang
                                          height: 120, // chiều dọc
                                          child: CircularProgressIndicator(
                                            strokeWidth:
                                                10, // độ dày của vòng tròn
                                            color:
                                                Colors.black, // màu vòng tròn
                                          ),
                                        ),
                                      )
                                    : Image.network(
                                        name_event["ads${index_event}"]["image1"],
                                        width: 185,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadiusGeometry.only(
                                  bottomRight: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ), // bo góc nếu muốn
                                child: name_event["ads${index_event}"] == null
                                    ? Padding(
                                        padding: EdgeInsetsGeometry.only(
                                          top: 5,
                                          bottom: 5,
                                          left: 30,
                                          right: 30,
                                        ),
                                        child: SizedBox(
                                          width: 120, // chiều ngang
                                          height: 120, // chiều dọc
                                          child: CircularProgressIndicator(
                                            strokeWidth:
                                                10, // độ dày của vòng tròn
                                            color:
                                                Colors.black, // màu vòng tròn
                                          ),
                                        ),
                                      )
                                    : Image.network(
                                        name_event["ads${index_event}"]["image2"],
                                        width: 185,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => change_index_event(0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: index_event == 0
                                      ? Color.fromRGBO(233, 83, 34, 1)
                                      : Color.fromRGBO(243, 233, 181, 1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () => change_index_event(1),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: index_event == 1
                                      ? Color.fromRGBO(233, 83, 34, 1)
                                      : Color.fromRGBO(243, 233, 181, 1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () => change_index_event(2),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: index_event == 2
                                      ? Color.fromRGBO(233, 83, 34, 1)
                                      : Color.fromRGBO(243, 233, 181, 1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () => change_index_event(3),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: index_event == 3
                                      ? Color.fromRGBO(233, 83, 34, 1)
                                      : Color.fromRGBO(243, 233, 181, 1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () => change_index_event(4),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: index_event == 4
                                      ? Color.fromRGBO(233, 83, 34, 1)
                                      : Color.fromRGBO(243, 233, 181, 1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () => move_page(Routers.contact),
          backgroundColor: Colors.white,
          child: Icon(Icons.support_agent_sharp, size: 40, color: Colors.red),
          shape: CircleBorder(
            side: BorderSide(
              color: Colors.red, // màu viền
              width: 5, // độ dày viền
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
          onTap: (index) {
            switch (index) {
              case 0:
                move_page(Routers.home);
                break;
              case 1:
                move_page(Routers.voucher);
                break;
              case 2:
                move_page(Routers.shop);
                break;
              case 3:
                move_page(Routers.notification);
                break;
              case 4:
                open_page_me();
                break;
            }
          },
          backgroundColor: Colors.red,
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
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.favorite),
              label: "Cửa hàng",
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
