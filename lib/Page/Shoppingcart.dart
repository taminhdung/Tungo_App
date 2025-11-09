import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../Routers.dart';
import '../model/food_show.dart';
import 'Me.dart';
import 'package:intl/intl.dart';
import '../Service.dart';

class Shoppingcart extends StatefulWidget {
  const Shoppingcart({super.key});
  State<Shoppingcart> createState() => _ShoppingcartState();
}

// crop ảnh thành vuông - chạy trong isolate để k lag UI
Uint8List _cropBytesIsolate(Uint8List inputBytes) {
  final original = img.decodeImage(inputBytes);
  if (original == null) {
    throw Exception('Không thể decode ảnh.');
  }

  // lấy cạnh nhỏ nhất làm size vuông
  final size = original.width < original.height
      ? original.width
      : original.height;
  final offsetX = ((original.width - size) / 2).round();
  final offsetY = ((original.height - size) / 2).round();

  final cropped = img.copyCrop(
    original,
    x: offsetX,
    y: offsetY,
    width: size,
    height: size,
  );

  final jpg = img.encodeJpg(cropped, quality: 90);
  return Uint8List.fromList(jpg);
}

class _ShoppingcartState extends State<Shoppingcart> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  Service service = Service();

  // data giỏ hàng
  Map<String, dynamic> cartItems = {};
  List<String> displayList = [];

  // trạng thái UI
  Map<String, bool> selectedItems = {};
  Map<String, int> quantities = {};
  Map<String, bool> itemsToDelete = {};
  Map<String, Map<String, String>> item_select_on_pay = {};
  bool isEditMode = false;

  // cache ảnh đã crop
  Map<String, String> _imageCache = {};
  Set<String> _processingImages = {};

  @override
  void initState() {
    super.initState();
    loadCartData();
    _searchController.addListener(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadCartData() async {
    final result = await service.get_order();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_item = {};
    Map<String, int> quality_value = {};
    for (int i = 0; i < data.length; i++) {
      map_item[i.toString()] = data[i];
      quality_value[i.toString()] = int.parse(
        map_item[i.toString()]['soluong'],
      );
      selectedItems[i.toString()] = false;
    }
    setState(() {
      cartItems = Map.from(map_item);
      quantities = Map.from(quality_value);
    });
  }

  void navigateToPage(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  Future<String?> getCroppedImage(String imageUrl) async {
    if (imageUrl.isEmpty) return null;

    // check cache
    if (_imageCache.containsKey(imageUrl)) {
      String cachedPath = _imageCache[imageUrl]!;
      if (await File(cachedPath).exists()) {
        return cachedPath;
      } else {
        _imageCache.remove(imageUrl);
      }
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return null;

      // crop ảnh trong isolate
      final croppedBytes = await compute<Uint8List, Uint8List>(
        _cropBytesIsolate,
        response.bodyBytes,
      );

      final tempDir = await getTemporaryDirectory();
      final fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      await File(filePath).writeAsBytes(croppedBytes);

      _imageCache[imageUrl] = filePath;
      return filePath;
    } catch (e) {
      debugPrint('Lỗi crop ảnh: $e');
      return null;
    }
  }

  void preloadImage(String url) {
    if (url.isEmpty ||
        _imageCache.containsKey(url) ||
        _processingImages.contains(url)) {
      return;
    }

    _processingImages.add(url);

    getCroppedImage(url)
        .then((path) {
          if (path != null && mounted) {
            precacheImage(FileImage(File(path)), context);
            setState(() {});
          }
          _processingImages.remove(url);
        })
        .catchError((e) {
          debugPrint('Preload failed: $e');
          _processingImages.remove(url);
        });
  }

  Future<void> add_order_shopping() async {
    try {
      await service.add_order_pay(item_select_on_pay);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Thêm thành công"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Thêm thất bại. Báo lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildFoodImage(String imageUrl) {
    const double imgSize = 86;
    String? cachedPath = _imageCache[imageUrl];

    // đã có cache -> dùng file local
    if (cachedPath != null && File(cachedPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(cachedPath),
          width: imgSize,
          height: imgSize,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildErrorImage(),
        ),
      );
    }

    // chưa có cache -> load từ network
    if (!_processingImages.contains(imageUrl)) {
      preloadImage(imageUrl);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: imgSize,
        height: imgSize,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: imgSize,
            height: imgSize,
            color: Colors.grey[200],
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (_, __, ___) => _buildErrorImage(),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: 86,
      height: 86,
      color: Colors.grey[200],
      child: Icon(Icons.broken_image, size: 36, color: Colors.grey),
    );
  }

  int calculateTotal() {
    int total = 0;

    cartItems.forEach((key, value) {
      if (selectedItems[key] == true) {
        var food = foodShow.fromJson(value);
        int price = int.parse(food.gia ?? "0");
        int discount = int.parse(food.giamgia ?? "0");

        // tính giá sau giảm
        int finalPrice = price - (price * discount ~/ 100);
        int qty = quantities[key] ?? 1;
        total += finalPrice * qty;
      }
    });

    return total;
  }

  void toggleSelectAll(bool selectAll) {
    setState(() {
      selectedItems.forEach((key, value) {
        selectedItems[key] = selectAll;
      });
    });
  }

  Future<void> deleteSelectedItems() async {
    List<String> toRemove = [];

    itemsToDelete.forEach((key, shouldDelete) {
      if (shouldDelete) toRemove.add(key);
    });

    if (toRemove.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Chưa chọn món nào để xóa")));
      return;
    }
    // rebuild cart
    List<Map<String, dynamic>> remainingItems = [];
    for (var i = 0; i < cartItems.length; i++) {
      String key = i.toString();
      if (!toRemove.contains(key)) {
        remainingItems.add(Map<String, dynamic>.from(cartItems[key]));
        await service.delete_order(key);
      }
    }

    Map<String, dynamic> newCart = {};
    for (var i = 0; i < remainingItems.length; i++) {
      newCart[i.toString()] = remainingItems[i];
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Xoá thành công"), backgroundColor: Colors.green),
    );
    navigateToPage(Routers.shoppingcart);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromRGBO(245, 203, 88, 1);
    const accentColor = Color.fromRGBO(233, 83, 34, 1);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Me(),
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        toolbarHeight: 150,
        leading: IconButton(
          onPressed: () => navigateToPage(Routers.home),
          icon: Icon(Icons.arrow_back_ios_new, color: accentColor),
        ),
        title: Text(
          "Giỏ hàng",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
                if (!isEditMode) {
                  itemsToDelete.updateAll((key, _) => false);
                }
              });
            },
            child: Text(
              isEditMode ? "Huỷ" : "Chỉnh sửa",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          if (isEditMode)
            IconButton(
              onPressed: deleteSelectedItems,
              icon: Icon(Icons.delete_forever, color: Colors.white),
            ),
          SizedBox(width: 6),
        ],
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              SizedBox(height: 12),

              // danh sách món
              Expanded(
                child: ListView.builder(
                  itemCount: displayList.isEmpty
                      ? cartItems.length
                      : displayList.length,
                  itemBuilder: (context, index) {
                    String itemKey = displayList.isEmpty
                        ? index.toString()
                        : displayList[index];

                    var itemData = cartItems[itemKey];
                    if (itemData == null) {
                      return Container(
                        height: 110,
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }

                    var food = foodShow.fromJson(itemData);

                    bool isSelected = isEditMode
                        ? (itemsToDelete[itemKey] ?? false)
                        : (selectedItems[itemKey] ?? false);

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // checkbox
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isEditMode) {
                                  itemsToDelete[itemKey] = !isSelected;
                                } else {
                                  selectedItems[itemKey] = !isSelected;
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.red : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ),

                          buildFoodImage(food.anh),
                          SizedBox(width: 12),

                          // thông tin món
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.ten,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "đ${food.gia}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // nút +/-
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (!((quantities[index.toString()]
                                              as int) <
                                          2)) {
                                        quantities[index.toString()] =
                                            (quantities[index.toString()]
                                                as int) -
                                            1;
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('${quantities[index.toString()] ?? 1}'),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      quantities[index.toString()] =
                                          (quantities[index.toString()]
                                              as int) +
                                          1;
                                    });
                                  },
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),

                  // chọn tất cả
                  GestureDetector(
                    onTap: () {
                      bool allSelected = selectedItems.values.every(
                        (v) => v == true,
                      );
                      toggleSelectAll(!allSelected);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color:
                                selectedItems.values.every((v) => v == true) &&
                                    selectedItems.isNotEmpty
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child:
                              selectedItems.values.every((v) => v == true) &&
                                  selectedItems.isNotEmpty
                              ? Icon(Icons.check, color: accentColor, size: 18)
                              : null,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Chọn Tất Cả',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // tổng tiền
                  Text(
                    NumberFormat.currency(
                      locale: "vi",
                      symbol: "₫",
                    ).format(calculateTotal()),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(width: 12),

                  // nút kiểm tra
                  GestureDetector(
                    onTap: () async {
                      item_select_on_pay.clear();
                      if (calculateTotal() == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Vui lòng chọn món trước khi kiểm tra",
                            ),
                          ),
                        );
                        return;
                      }
                      int count=-1;
                      for (int i = 0; i < selectedItems.length; i++) {
                        if (selectedItems[i.toString()] == true) {
                          count++;
                          item_select_on_pay['item$count'] = {
                            'id': i.toString(),
                            'anh': "",
                            'ten': '',
                            'gia': '',
                            'soluong': "",
                          };
                          item_select_on_pay['item$count']?['anh'] =
                              cartItems[i.toString()]['anh'];
                          item_select_on_pay['item$count']?['ten'] =
                              cartItems[i.toString()]['ten'];
                          item_select_on_pay['item$count']?['gia'] =
                              (int.parse(cartItems[i.toString()]['gia']) *
                                      int.parse(
                                        cartItems[i.toString()]['soluong'],
                                      ))
                                  .toString();
                          item_select_on_pay['item$count']?['soluong'] =
                              (quantities[i.toString()]).toString();
                        }
                      }
                      await add_order_shopping();
                      navigateToPage(Routers.orders);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        "Kiểm Tra",
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
