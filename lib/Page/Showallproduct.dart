import 'package:flutter/material.dart';
import '../Routers.dart';
import '../Service.dart';
import '../model/product_show.dart';
import 'Me.dart';

class Showallproduct extends StatefulWidget {
  const Showallproduct({super.key});
  State<Showallproduct> createState() => _ShowallproductState();
}

class _ShowallproductState extends State<Showallproduct> {
  final service = Service();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> item = {};
  Map<String, dynamic> item1 = {};
  Map<String, dynamic> item2 = {};
  Map<String, dynamic> item3 = {};
  @override
  void initState() {
    super.initState();
    loadData();
  }

  int index_bottom_button = 0;

  void loadData() async {
    await get_Item();
    await get_Item_bestseller();
    await get_Item_sale();
  }

  void move_page(String path) {
    Navigator.pushReplacementNamed(context, path);
  }

  void open_page_me() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> get_Item() async {
    final result = await service.getlist();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_item = {};
    for (int i = 0; i < data.length; i++) {
      map_item["item$i"] = data[i];
    }
    setState(() {
      item = Map.from(map_item);
      item1 = Map.from(item);
    });
  }

  Future<void> get_Item_bestseller() async {
    List<Map<String, dynamic>> listItem = item.values
        .cast<Map<String, dynamic>>()
        .toList();

    listItem.sort((a, b) {
      int sa = int.tryParse(a['sohangdaban'].toString()) ?? 0;
      int sb = int.tryParse(b['sohangdaban'].toString()) ?? 0;
      return sb.compareTo(sa); // giảm dần
    });

    // convert lại về map
    Map<String, dynamic> sortedItem = {};
    for (int i = 0; i < listItem.length; i++) {
      sortedItem["item$i"] = listItem[i];
    }

    setState(() {
      item2 = sortedItem;
    });
  }

  Future<void> get_Item_sale() async {
    item3.clear();
    int count = -1;
    for (int i = 0; i < item.length; i++) {
      int sold = int.tryParse(item["item$i"]['giamgia'].toString()) ?? 0;
      if (sold > 0) {
        count++;
        item3["item$count"] = item["item$i"];
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      key: _scaffoldKey,
      endDrawer: Me(),
      backgroundColor: Color.fromRGBO(245, 203, 88, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 150,
        leading: IconButton(
          onPressed: () => move_page(Routers.home),
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
        actions: const <Widget>[SizedBox(width: 0)],
      ),
      body: Container(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {
                            item.clear();
                            setState(() {
                              item = Map.from(item1);
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 2,
                            ),
                            backgroundColor: Color.fromRGBO(233, 83, 34, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Tất cả",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            item.clear();
                            setState(() {
                              item=Map.from(item2);
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 2,
                            ),
                            backgroundColor: Color.fromRGBO(233, 83, 34, 1),
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
                            item.clear();
                            setState(() {
                              item=Map.from(item3);
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 2,
                            ),
                            backgroundColor: Color.fromRGBO(233, 83, 34, 1),
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
                      itemCount: item.length < 5 ? 5 : item.length,
                      itemBuilder: (context, index) {
                        if (item["item$index"] == null) {
                          return SizedBox();
                        }
                        final products = ProductShow.fromJson(
                          item["item${index}"],
                        );
                        return item["item$index"] != null
                            ? Container(
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
                                      child: products.anh.isEmpty
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
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 10),
                                                    Text(
                                                      products.ten,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      "đ${products.gia}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                    SizedBox(height: 7),
                                                    Text(
                                                      "Giảm giá ${products.giamgia}%",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          size: 14,
                                                          color: Colors.grey,
                                                        ),
                                                        SizedBox(width: 1),
                                                        Text(
                                                          products.diachi,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 76),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              products.sao,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          "Đã bán ${products.sohangdaban}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ), // This closing parenthesis was misplaced.
                              )
                            : SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.red,
            currentIndex: index_bottom_button,
            onTap: (index) {
              setState(() {
                index_bottom_button = index;
              });
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
      ),
    ));
  }
}
