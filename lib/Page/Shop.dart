import 'dart:io';
import 'package:flutter/material.dart';
import '../Routers.dart';
import '../Service.dart';
import '../model/food_show.dart';
import 'Me.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  int selectedIndex = -1;
  final service = Service();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> item = {};

  final TextEditingController tenController = TextEditingController();
  final TextEditingController giaController = TextEditingController();
  final TextEditingController giamGiaController = TextEditingController();
  final TextEditingController diaChiController = TextEditingController();
  final TextEditingController tenSukienController = TextEditingController();
  final TextEditingController kieuMonanController = TextEditingController();
  static String? _tempImageUrl;
  static File? _image_path;

  @override
  void initState() {
    super.initState();
    get_Item();
  }

  void move_page(String path) {
    Navigator.pushReplacementNamed(context, path);
  }

  void get_Item() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await service.getlist();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_item = {};
    Map<String, dynamic> map_item1 = {};
    int count = -1;
    for (int i = 0; i < data.length; i++) {
      map_item["item$i"] = data[i];
    }
    for (int i = 0; i < map_item.length; i++) {
      if (map_item['item$i']['useruid'] == prefs.getString("uid")) {
        count++;
        map_item1["item$count"] = map_item['item$i'];
      }
    }
    setState(() {
      item = map_item1;
      print(item);
    });
  }

  Future<void> upload_image(ten, gia, tensukien, giamgia, type, diachi) async {
    final link_image = await service.uploadImage(_image_path!);
    final flag1 = await service.add_food(
      link_image!,
      ten,
      gia,
      tensukien,
      giamgia,
      type,
      diachi,
    );
    if (link_image != "") {
      return;
    } else {
      print('tải ảnh lên thất bại.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("tải ảnh lên thất bại."),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (flag1) {
      return;
    } else {
      print('Lưu dữ liệu thất bại');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lưu dữ liệu thất bại"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void hienHopThemMon() {
    _tempImageUrl = null;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                "Thêm món ăn",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 180,
                      width: 500,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_tempImageUrl != null &&
                              _tempImageUrl!.toString().contains("'"))
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_tempImageUrl!.toString().split("'")[1]),
                                width: 250,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final _imageurl = await service.getImage();
                                if (_imageurl == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Không chọn được ảnh, thử lại.",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setStateDialog(() {
                                  _tempImageUrl = _imageurl.toString();
                                  if (_tempImageUrl!.contains("'")) {
                                    _image_path = File(
                                      _tempImageUrl!.toString().split("'")[1],
                                    );
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                backgroundColor: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(
                                Icons.upload,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                "Tải ảnh lên",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: tenController,
                      decoration: const InputDecoration(
                        labelText: "Tên món ăn",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: giaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá món ăn",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tenSukienController,
                      decoration: const InputDecoration(
                        labelText: "Tên sự kiện",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: giamGiaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giảm giá (%)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: kieuMonanController,
                      decoration: const InputDecoration(
                        labelText: "Kiểu món ăn",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: diaChiController,
                      decoration: const InputDecoration(
                        labelText: "Địa chỉ",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    tenController.clear();
                    giaController.clear();
                    tenSukienController.clear();
                    giamGiaController.clear();
                    kieuMonanController.clear();
                    diaChiController.clear();
                    setStateDialog(() {
                      _tempImageUrl = null;
                    });
                  },
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final ten = tenController.text.trim();
                    final gia = giaController.text.trim();
                    final tensukien = tenSukienController.text.trim();
                    final giamgia = giamGiaController.text.trim();
                    final type = kieuMonanController.text.trim();
                    final diachi = diaChiController.text.trim();

                    if (ten.isEmpty ||
                        gia.isEmpty ||
                        tensukien.isEmpty ||
                        giamgia.isEmpty ||
                        type.isEmpty ||
                        diachi.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Vui lòng nhập đầy đủ tất cả thông tin món ăn.",
                          ),
                        ),
                      );
                      return;
                    }

                    if (_image_path == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Vui lòng tải ảnh món ăn trước."),
                        ),
                      );
                      return;
                    }

                    await upload_image(
                      ten,
                      gia,
                      tensukien,
                      giamgia,
                      type,
                      diachi,
                    );

                    Navigator.pop(context);
                    tenController.clear();
                    giaController.clear();
                    tenSukienController.clear();
                    giamGiaController.clear();
                    kieuMonanController.clear();
                    diaChiController.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đã thêm món ăn thành công!"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(233, 83, 34, 1),
                  ),
                  child: const Text(
                    "Thêm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void hienHopSuaMon(foodShow Foods) {
    tenController.text = Foods.ten ?? '';
    giaController.text = Foods.gia?.toString() ?? '';
    tenSukienController.text = Foods.tensukien ?? '';
    giamGiaController.text = Foods.giamgia?.toString() ?? '';
    kieuMonanController.text = Foods.type ?? '';
    diaChiController.text = Foods.diachi ?? '';

    String? _tempImageUrl = Foods.anh;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                "Chỉnh sửa món ăn",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 180,
                      width: 500,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_tempImageUrl != null &&
                              _tempImageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _tempImageUrl!,
                                width: 250,
                                height: 300,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                    ),
                              ),
                            ),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final _imageurl = await service.getImage();
                                if (_imageurl == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Không chọn được ảnh mới."),
                                    ),
                                  );
                                  return;
                                }
                                setStateDialog(() {
                                  _tempImageUrl = _imageurl.toString();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                backgroundColor: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(
                                Icons.upload,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                "Tải ảnh lên",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: tenController,
                      decoration: const InputDecoration(
                        labelText: "Tên món ăn",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: giaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá món ăn",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tenSukienController,
                      decoration: const InputDecoration(
                        labelText: "Tên sự kiện",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: giamGiaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giảm giá (%)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: kieuMonanController,
                      decoration: const InputDecoration(
                        labelText: "Kiểu món ăn",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: diaChiController,
                      decoration: const InputDecoration(
                        labelText: "Địa chỉ",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    tenController.clear();
                    giaController.clear();
                    tenSukienController.clear();
                    giamGiaController.clear();
                    kieuMonanController.clear();
                    diaChiController.clear();
                  },
                  child: const Text("Huỷ"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final ten = tenController.text.trim();
                    final gia = giaController.text.trim();
                    final tensk = tenSukienController.text.trim();
                    final giam = giamGiaController.text.trim();
                    final kieu = kieuMonanController.text.trim();
                    final diachi = diaChiController.text.trim();

                    if (ten.isEmpty ||
                        gia.isEmpty ||
                        tensk.isEmpty ||
                        giam.isEmpty ||
                        kieu.isEmpty ||
                        diachi.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Vui lòng nhập đầy đủ tất cả thông tin món ăn.",
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã lưu thay đổi món ăn.")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(233, 83, 34, 1),
                  ),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Me(),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 180,
            color: const Color.fromRGBO(245, 203, 88, 1),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => move_page(Routers.home),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color.fromRGBO(233, 83, 34, 1),
                          size: 26,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Cửa hàng",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 160),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 0),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 15,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: item.length < 5 ? 5 : item.length,
                      itemBuilder: (context, index) {
                        if (item["item$index"] == null) return const SizedBox();
                        final Foods = foodShow.fromJson(item["item$index"]);
                        return GestureDetector(
                          onLongPress: () {
                            setState(() => selectedIndex = index);
                          },
                          onTap: () {
                            setState(() => selectedIndex = -1);
                          },
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
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
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                      child: Foods.anh.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.all(30),
                                              child: SizedBox(
                                                width: 110,
                                                height: 110,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                          : Image.network(
                                              Foods.anh,
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Text(
                                            Foods.ten,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "đ${Foods.gia}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Giảm giá ${Foods.giamgia}%",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 1),
                                              Text(
                                                Foods.diachi,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 76),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              Foods.sao,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          "Đã bán ${Foods.sohangdaban}",
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
                              if (selectedIndex == index)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 80,
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(150, 0, 0, 0),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            tenController.text = Foods.ten;
                                            giaController.text = Foods.gia
                                                .toString();
                                            tenSukienController.text =
                                                Foods.tensukien;
                                            giamGiaController.text = Foods
                                                .giamgia
                                                .toString();
                                            kieuMonanController.text =
                                                Foods.type;
                                            diaChiController.text =
                                                Foods.diachi;
                                            hienHopSuaMon(Foods);
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  title: const Text(
                                                    "Xác nhận xóa",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    "Bạn có chắc chắn muốn xóa món '${Foods.ten}' không?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("Huỷ"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              "Đã xóa món '${Foods.ten}' thành công!",
                                                            ),
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                          ),
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            const Color.fromRGBO(
                                                              233,
                                                              83,
                                                              34,
                                                              1,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        "Xoá",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(233, 83, 34, 1),
        shape: const CircleBorder(),
        onPressed: hienHopThemMon,
        child: const Icon(Icons.add, color: Colors.white, size: 25),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          height: 65,
          color: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(
                Icons.home_outlined,
                "Trang chủ",
                () => move_page(Routers.home),
              ),
              buildNavItem(
                Icons.discount_outlined,
                "Mã giảm giá",
                () => move_page(Routers.voucher),
              ),
              const SizedBox(width: 40),
              buildNavItem(
                Icons.notifications_outlined,
                "Thông báo",
                () => move_page(Routers.notification),
              ),
              buildNavItem(
                Icons.person_outline,
                "Tôi",
                () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
