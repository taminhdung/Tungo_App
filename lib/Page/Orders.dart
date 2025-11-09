import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../Routers.dart';
import '../model/food_show.dart';
import 'Me.dart';
import 'FoodDetail.dart';
import 'package:intl/intl.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});
  State<Orders> createState() => _OrdersState();
}

// crop ảnh về hình vuông
Uint8List _cropBytesIsolate(Uint8List inputBytes) {
  final original = img.decodeImage(inputBytes);
  if (original == null) {
    throw Exception('Không thể decode ảnh.');
  }

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

class _OrdersState extends State<Orders> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // data đơn hàng
  Map<String, dynamic> orderItems = {};
  Map<String, int> quantities = {};

  // cache ảnh
  Map<String, String> _imageCache = {};
  Set<String> _processingImages = {};

  @override
  void initState() {
    super.initState();
    loadOrderData();
  }

  void loadOrderData() {
    // TODO: replace with real API
    final fakeData = [
      {
        "id": "f1",
        "ten": "Cơm gà xối mỡ",
        "gia": "160000",
        "tensukien": "Đùi nhỏ",
        "giamgia": "0",
        "type": "Cơm",
        "diachi": "TP. Hồ Chí Minh",
        "anh":
            "https://cdn.xanhsm.com/2025/01/7f24de71-bun-rieu-quy-nhon-1.jpg",
        "sao": "4.8",
        "sohangdaban": "120",
        "extras": [
          {"name": "Đùi nhỏ", "price": 5000},
          {"name": "Trà đá", "price": 2000},
        ],
      },
      {
        "id": "f2",
        "ten": "Phở bò tái",
        "gia": "90000",
        "tensukien": "Đặc biệt",
        "giamgia": "10",
        "type": "Phở",
        "diachi": "Hà Nội",
        "anh":
            "https://images.unsplash.com/photo-1604908177522-4d6d9f3b3a2f?w=800&q=80",
        "sao": "4.6",
        "sohangdaban": "85",
        "extras": [
          {"name": "Đặc biệt", "price": 0},
        ],
      },
      {
        "id": "f3",
        "ten": "Bún riêu",
        "gia": "70000",
        "tensukien": "chả",
        "giamgia": "5",
        "type": "Bún",
        "diachi": "Quy Nhơn",
        "anh":
            "https://cdn.xanhsm.com/2025/01/7f24de71-bun-rieu-quy-nhon-1.jpg",
        "sao": "4.4",
        "sohangdaban": "60",
        "extras": [
          {"name": "Chả", "price": 3000},
        ],
      },
    ];

    Map<String, dynamic> temp = {};
    for (var i = 0; i < fakeData.length; i++) {
      String key = "item$i";
      temp[key] = fakeData[i];
      quantities[key] = 1;
    }

    setState(() {
      orderItems = temp;
    });
  }

  void navigateToPage(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  Future<String?> getCroppedImage(String imageUrl) async {
    if (imageUrl.isEmpty) return null;

    // check cache trước
    if (_imageCache.containsKey(imageUrl)) {
      String cachedPath = _imageCache[imageUrl]!;
      if (await File(cachedPath).exists()) {
        return cachedPath;
      }
      _imageCache.remove(imageUrl);
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return null;

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
        _processingImages.contains(url))
      return;

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

  Widget buildFoodImage(String imageUrl) {
    const double imgSize = 86;
    String? cachedPath = _imageCache[imageUrl];

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

    if (!_processingImages.contains(imageUrl)) preloadImage(imageUrl);

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

  // tính tổng giá món ăn (chưa tính extras)
  int calculateBaseTotal() {
    int total = 0;

    orderItems.forEach((key, value) {
      var food = foodShow.fromJson(value);
      int price = int.tryParse(food.gia ?? "0") ?? 0;
      int discount = int.tryParse(food.giamgia ?? "0") ?? 0;

      // giá sau giảm
      int finalPrice = price - (price * discount ~/ 100);
      int qty = quantities[key] ?? 1;

      total += finalPrice * qty;
    });

    return total;
  }

  // tính tổng tiền món thêm
  int calculateExtrasTotal() {
    int extrasTotal = 0;

    orderItems.forEach((key, value) {
      int qty = quantities[key] ?? 1;
      final extras = value['extras'];

      if (extras is List) {
        for (var ex in extras) {
          if (ex is! Map) continue;

          final p = ex['price'] ?? 0;
          int price = 0;

          if (p is int) {
            price = p;
          } else if (p is String) {
            price = int.tryParse(p) ?? 0;
          }

          extrasTotal += price * qty;
        }
      }
    });

    return extrasTotal;
  }

  // format text hiển thị món thêm
  String extrasDescriptionForItem(Map<String, dynamic> item) {
    final extras = item['extras'];

    if (extras is List && extras.isNotEmpty) {
      List<String> parts = [];

      for (var ex in extras) {
        if (ex is! Map) continue;

        final name = ex['name'] ?? '';
        final p = ex['price'] ?? 0;
        int price = 0;

        if (p is int) {
          price = p;
        } else if (p is String) {
          price = int.tryParse(p) ?? 0;
        }

        String priceStr = NumberFormat.currency(
          locale: "vi",
          symbol: "₫",
        ).format(price);

        parts.add('$name ($priceStr)');
      }

      return parts.join(', ');
    } else {
      // fallback về tensukien cũ
      final tensukien = item['tensukien'];
      if (tensukien != null && tensukien.toString().trim().isNotEmpty) {
        return tensukien.toString();
      }
      return '---';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromRGBO(245, 203, 88, 1);
    const accentColor = Color.fromRGBO(233, 83, 34, 1);

    final productCount = orderItems.length;
    final baseTotal = calculateBaseTotal();
    final extrasTotal = calculateExtrasTotal();
    const int shippingFee = 15000;
    final grandTotal = baseTotal + extrasTotal + shippingFee;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        toolbarHeight: 150,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => navigateToPage(Routers.home),
          icon: Icon(Icons.arrow_back_ios_new, color: accentColor),
        ),
        title: Text(
          "Đơn hàng của bạn",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
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
              // header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Bạn có $productCount món ăn trong đơn hàng",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(height: 12),

              // danh sách món
              Expanded(
                child: ListView.builder(
                  itemCount: orderItems.length,
                  itemBuilder: (context, index) {
                    String key = "item$index";
                    var itemData = orderItems[key];

                    if (itemData == null) return SizedBox.shrink();

                    var food = foodShow.fromJson(itemData);

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
                          buildFoodImage(food.anh),
                          SizedBox(width: 12),
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
                                  "Món thêm: ${extrasDescriptionForItem(itemData)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "đ${NumberFormat.decimalPattern('vi').format((int.parse("${int.parse(food.gia) - ((int.parse(food.gia) * int.parse(food.giamgia)) ~/ 100)}")))}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.orange,
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

              SizedBox(height: 12),

              // tổng kết
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriceRow("Giá", baseTotal),
                    SizedBox(height: 8),
                    _buildPriceRow("Món thêm", extrasTotal),
                    SizedBox(height: 8),
                    _buildPriceRow("Vận chuyển", shippingFee),
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tổng tiền",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: "vi",
                            symbol: "₫",
                          ).format(grandTotal),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () {
                            if (calculateBaseTotal() == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Giỏ hàng rỗng")),
                              );
                              return;
                            }
                            navigateToPage(Routers.notification);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Thanh Toán",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // helper để build row giá
  Widget _buildPriceRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
        Text(
          NumberFormat.currency(locale: "vi", symbol: "₫").format(amount),
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
