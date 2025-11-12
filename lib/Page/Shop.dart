import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../Routers.dart';
import '../Service.dart';
import '../model/food_show.dart';
import 'Me.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});
  State<Shop> createState() => _ShopState();
}

/// Isolate worker: nhận Uint8List, decode, crop center square, encode lại và trả về Uint8List.
Uint8List _cropBytesIsolate(Uint8List inputBytes) {
  final img.Image? original = img.decodeImage(inputBytes);
  if (original == null) {
    throw Exception('Không thể decode ảnh.');
  }

  final int size = original.width < original.height
      ? original.width
      : original.height;
  final int offsetX = ((original.width - size) / 2).round();
  final int offsetY = ((original.height - size) / 2).round();

  final img.Image cropped = img.copyCrop(
    original,
    x: offsetX,
    y: offsetY,
    width: size,
    height: size,
  );

  // Nếu muốn resize cố định (ví dụ 1080) có thể bật dòng sau:
  // final img.Image resized = img.copyResize(cropped, width: 1080, height: 1080);

  final List<int> jpg = img.encodeJpg(cropped, quality: 90);
  return Uint8List.fromList(jpg);
}

class _ShopState extends State<Shop> with WidgetsBindingObserver {
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
  final TextEditingController motacontroller = TextEditingController();
  static String? _tempImageUrl;
  static File? _image_path;
  bool _isbutton = true;
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
    });
  }

  Future<void> add_food_shop(
    ten,
    gia,
    tensukien,
    giamgia,
    type,
    diachi,
    mota,
  ) async {
    String? link_image;
    String flag = "true";
    if (_image_path != null) {
      String? link_image1 = await service.uploadImagefood(_image_path!);
      setState(() {
        link_image = link_image1;
      });
      if (link_image == "") {
        print('tải ảnh lên thất bại.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("tải ảnh lên thất bại."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    final flag1 = await service.add_food(
      link_image!,
      ten,
      gia,
      tensukien,
      giamgia,
      type,
      diachi,
      mota,
    );
    if (!flag1) {
      print('Lưu dữ liệu thất bại');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lưu dữ liệu thất bại"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thêm thành công"), backgroundColor: Colors.green),
    );
  }

  Future<void> update_food_shop(
    link_image_old,
    id,
    ten,
    gia,
    tensukien,
    giamgia,
    type,
    diachi,
    mota,
  ) async {
    String? link_image = link_image_old;
    if (_image_path != null) {
      final flag0 = await service.DeleteImagefood(link_image_old);
      if (flag0 == "") {
        print('Xoá ảnh thất bại.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xoá ảnh thất bại."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final link_image1 = await service.uploadImagefood(_image_path!);
      setState(() {
        link_image = link_image1;
      });
      if (link_image == "") {
        print('tải ảnh lên thất bại.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("tải ảnh lên thất bại."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    final flag1 = await service.update_food(
      id,
      link_image!,
      ten,
      gia,
      tensukien,
      giamgia,
      type,
      diachi,
      mota,
    );

    if (!flag1) {
      print('Lưu dữ liệu thất bại');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lưu dữ liệu thất bại"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lưu thành công"), backgroundColor: Colors.green),
    );
  }

  Future<void> delete_food_shop(id, link_image_old) async {
    final flag0 = await service.DeleteImagefood(link_image_old);
    if (flag0 == "") {
      print('Xoá ảnh thất bại.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Xoá ảnh thất bại."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final flag1 = await service.delete_food(id);
    if (!flag1) {
      print('Xoá food thất bại.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Xoá food thất bại."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Xoá thành công"), backgroundColor: Colors.green),
    );
  }

  /// Helper: crop file to center-square in a background isolate and save to temp file.
  Future<File?> _autoCropFile(File inputFile) async {
    try {
      final Uint8List bytes = await inputFile.readAsBytes();
      // Run crop in isolate
      final Uint8List croppedBytes = await compute<Uint8List, Uint8List>(
        _cropBytesIsolate,
        bytes,
      );
      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath);
      await outFile.writeAsBytes(croppedBytes);
      return outFile;
    } catch (e) {
      // Nếu có lỗi decode/crop, trả về null
      debugPrint('Auto crop error: $e');
      return null;
    }
  }

  void hienHopThemMon() {
    _tempImageUrl = null;
    showDialog(
      context: context,
      barrierDismissible: false,
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

                                // service.getImage() dường như trả về String chứa đường dẫn như "File('...')"
                                String raw = _imageurl.toString();
                                String path;
                                if (raw.contains("'")) {
                                  path = raw.split("'")[1];
                                } else {
                                  path = raw;
                                }

                                final File original = File(path);

                                // --- NEW: auto crop trước khi gán vào _image_path ---
                                final File? cropped = await _autoCropFile(
                                  original,
                                );
                                if (cropped == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Không xử lý được ảnh, thử lại.",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setStateDialog(() {
                                  // giữ định dạng cũ để code hiện tại còn dùng split("'")[1]
                                  _tempImageUrl = "'${cropped.path}'";
                                });
                                setState(() {
                                  _image_path = cropped;
                                  _tempImageUrl = "'${cropped.path}'";
                                });
                                // --- END NEW ---
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: motacontroller,
                      decoration: const InputDecoration(
                        labelText: "Mô tả",
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
                    motacontroller.clear();
                    setStateDialog(() {
                      _tempImageUrl = null;
                    });
                    setState(() {
                      _image_path = null;
                      _tempImageUrl = null;
                    });
                  },
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_isbutton) {
                      _isbutton = false;
                      final ten = tenController.text.trim();
                      final gia = giaController.text.trim();
                      final tensukien = tenSukienController.text.trim();
                      final giamgia = giamGiaController.text.trim();
                      final type = kieuMonanController.text.trim();
                      final diachi = diaChiController.text.trim();
                      final mota = motacontroller.text.trim();

                      if (ten.isEmpty ||
                          gia.isEmpty ||
                          tensukien.isEmpty ||
                          giamgia.isEmpty ||
                          type.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Vui lòng nhập đầy đủ tất cả thông tin món ăn.",
                            ),
                          ),
                        );
                        _isbutton = true;
                        return;
                      }

                      if (_image_path == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vui lòng tải ảnh món ăn trước."),
                          ),
                        );
                        _isbutton = true;
                        return;
                      }

                      await add_food_shop(
                        ten,
                        gia,
                        tensukien,
                        giamgia,
                        type,
                        diachi,
                        mota,
                      );
                      setState(() {
                        _image_path = null;
                        _tempImageUrl = null;
                      });
                      _isbutton = true;
                      Navigator.pop(context);
                      tenController.clear();
                      giaController.clear();
                      tenSukienController.clear();
                      giamGiaController.clear();
                      kieuMonanController.clear();
                      diaChiController.clear();
                      move_page(Routers.shop);
                    }
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
    motacontroller.text = Foods.mota ?? "";
    _tempImageUrl = null;
    showDialog(
      context: context,
      barrierDismissible: false,
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
                          (_tempImageUrl != null && _tempImageUrl!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(
                                      _tempImageUrl!.toString().split("'")[1],
                                    ),
                                    width: 250,
                                    height: 300,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                              size: 60,
                                            ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    Foods.anh,
                                    width: 250,
                                    height: 300,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
                                      content: Text(
                                        "Không chọn được ảnh, thử lại.",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // service.getImage() dường như trả về String chứa đường dẫn như "File('...')"
                                String raw = _imageurl.toString();
                                String path;
                                if (raw.contains("'")) {
                                  path = raw.split("'")[1];
                                } else {
                                  path = raw;
                                }

                                final File original = File(path);

                                // --- NEW: auto crop trước khi gán vào _image_path ---
                                final File? cropped = await _autoCropFile(
                                  original,
                                );
                                if (cropped == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Không xử lý được ảnh, thử lại.",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setStateDialog(() {
                                  _tempImageUrl = "'${cropped.path}'";
                                  // note: giữ _tempImageUrl theo format cũ để phần hiển thị hiện tại hoạt động
                                });
                                setState(() {
                                  _image_path = cropped;
                                  _tempImageUrl = "'${cropped.path}'";
                                });
                                // --- END NEW ---
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: motacontroller,
                      decoration: const InputDecoration(
                        labelText: "Mô tả",
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
                    motacontroller.clear();
                    setState(() {
                      _image_path = null;
                      _tempImageUrl = null;
                    });
                  },
                  child: const Text("Huỷ"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_isbutton) {
                      _isbutton = false;
                      final ten = tenController.text.trim();
                      final gia = giaController.text.trim();
                      final tensk = tenSukienController.text.trim();
                      final giam = giamGiaController.text.trim();
                      final kieu = kieuMonanController.text.trim();
                      final diachi = diaChiController.text.trim();
                      final mota = diaChiController.text.trim();

                      if (ten.isEmpty ||
                          gia.isEmpty ||
                          tensk.isEmpty ||
                          giam.isEmpty ||
                          kieu.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Vui lòng nhập đầy đủ tất cả thông tin món ăn.",
                            ),
                          ),
                        );
                        _isbutton = true;
                        return;
                      }

                      if (_image_path == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vui lòng tải ảnh món ăn trước."),
                          ),
                        );
                        _isbutton = true;
                        return;
                      }
                      await update_food_shop(
                        Foods.anh,
                        Foods.id,
                        ten,
                        gia,
                        tensk,
                        giam,
                        kieu,
                        diachi,
                        mota,
                      );
                      setState(() {
                        _image_path = null;
                        _tempImageUrl = null;
                      });
                      Navigator.pop(context);
                      _isbutton = true;
                      move_page(Routers.shop);
                    }
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
                                            "đ${NumberFormat.decimalPattern('vi').format((int.parse("${int.parse(Foods.gia) - ((int.parse(Foods.gia) * int.parse(Foods.giamgia)) ~/ 100)}")))}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            Foods.tensukien,
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
                                          "Đã bán ${int.parse(Foods.sohangdaban) > 1000 && 99999 > int.parse(Foods.sohangdaban)
                                              ? Foods.sohangdaban.toString().substring(0, 1) + "K"
                                              : int.parse(Foods.sohangdaban) > 10000 && 999999 > int.parse(Foods.sohangdaban)
                                              ? Foods.sohangdaban.toString().substring(0, 2) + "K"
                                              : int.parse(Foods.sohangdaban) > 100000 && 9999999 > int.parse(Foods.sohangdaban)
                                              ? Foods.sohangdaban.toString().substring(0, 3) + "K"
                                              : int.parse(Foods.sohangdaban) > 1000000 && 99999999 > int.parse(Foods.sohangdaban)
                                              ? Foods.sohangdaban.toString().substring(0, 1) + "M"
                                              : int.parse(Foods.sohangdaban) > 10000000 && 999999999 > int.parse(Foods.sohangdaban)
                                              ? Foods.sohangdaban.toString().substring(0, 2) + "M"
                                              : int.parse(Foods.sohangdaban) > 100000000 && 999999999 > int.parse(Foods.sohangdaban)
                                              ? Foods.sohangdaban.toString().substring(0, 3) + "M"
                                              : int.parse(Foods.sohangdaban) > 1000000000 && 2147483648 > int.parse(Foods.sohangdaban)
                                              ? Foods.sohangdaban.toString().substring(0, 1) + "B"
                                              : Foods.sohangdaban}",
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
                                                      onPressed: () async {
                                                        await delete_food_shop(
                                                          Foods.id,
                                                          Foods.anh,
                                                        );
                                                        Navigator.pop(context);
                                                        move_page(Routers.shop);
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
