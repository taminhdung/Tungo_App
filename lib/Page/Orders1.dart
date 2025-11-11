// lib/Page/Orders.dart
// Phiên bản có chú thích (notes) — đã sửa lỗi interpolation '$' để code chạy.

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../Routers.dart';
import '../model/food_show.dart';
import 'package:intl/intl.dart';
import '../Service.dart';
import 'payment_qr.dart';

// Widget quản lý trang Đơn hàng
class Orders1 extends StatefulWidget {
  const Orders1({super.key});
  State<Orders1> createState() => _OrdersState1();
}

// --- Helper để crop ảnh trong isolate (được gọi bằng compute) ---
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

class _OrdersState1 extends State<Orders1> with WidgetsBindingObserver {
  // key cho scaffold để xử lý snackbar / dialog (nếu cần)
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Service tương tác backend (class của bạn, giữ nguyên)
  Service service = Service();

  // --- Dữ liệu đơn hàng ---
  // orderItems: lưu thông tin từng món trong đơn (lấy từ API service.get_order_pay)
  Map<String, dynamic> orderItems = {};
  // quantities: số lượng tương ứng cho mỗi item (key là index chuỗi như '0','1',...)
  Map<String, int> quantities = {};

  // --- Lưu cache ảnh (tùy chọn) ---
  // _imageCache: ánh xạ url -> path file tạm đã crop
  Map<String, String> _imageCache = {};
  // _processingImages: set các url đang được xử lý để tránh xử lý trùng
  Set<String> _processingImages = {};

  // --- Trạng thái / tổng tiền ---
  int grandTotal = 0; // tổng cuối cùng (tính trên build)
  bool _isbutton = true; // disable/enable button khi đang xử lý
  String _paymentMethod = 'cash'; // phương thức thanh toán mặc định

  // Trạng thái tab: cửa hàng (shop) hoặc người dùng (customer)
  bool isShopSelected = true;

  @override
  void initState() {
    super.initState();
    load(); // tải dữ liệu ban đầu
  }

  // load() gọi các hàm fetch data (chỉ hàng, không include voucher vì đã bỏ)
  Future<void> load() async {
    await loadOrderData();
    // chú: đã bỏ loadVoucher theo yêu cầu
  }

  // Lấy dữ liệu đơn hàng từ Service
  Future<void> loadOrderData() async {
    try {
      final result = await service.get_order_pay();
      // đảm bảo result là list map
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        result ?? [],
      );
      Map<String, dynamic> map_item = {};
      for (int i = 0; i < data.length; i++) {
        map_item[i.toString()] = data[i];
        // set mặc định số lượng nếu API trả về trường 'soluong'
        quantities[i.toString()] =
            int.tryParse(data[i]['soluong']?.toString() ?? '') ?? 1;
      }
      setState(() {
        orderItems = Map.from(map_item);
      });
    } catch (e) {
      // ghi log lỗi, không crash
      debugPrint('loadOrderData error: $e');
    }
  }

  // Hàm điều hướng về trang khác trong app (dùng pushReplacementNamed)
  void navigateToPage(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  // --- Ảnh: crop + cache (tùy chọn) ---
  // Trả về path của file đã crop (ghi vào temp dir)
  Future<String?> getCroppedImage(String imageUrl) async {
    if (imageUrl.isEmpty) return null;

    // nếu đã cache và file tồn tại -> dùng luôn
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

      // dùng compute để chạy _cropBytesIsolate trong isolate khác (không block UI)
      final croppedBytes = await compute<Uint8List, Uint8List>(
        _cropBytesIsolate,
        response.bodyBytes,
      );

      final tempDir = await getTemporaryDirectory();
      final fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      await File(filePath).writeAsBytes(croppedBytes);

      _imageCache[imageUrl] = filePath; // lưu cache
      return filePath;
    } catch (e) {
      debugPrint('Lỗi crop ảnh: $e');
      return null;
    }
  }

  // Preload ảnh: tránh load nhiều lần, gọi precacheImage để tăng trải nghiệm
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

  // buildFoodImage: hiển thị ảnh (dùng cache nếu có), fallback nếu lỗi
  Widget buildFoodImage(String imageUrl) {
    const double imgSize = 70;
    String? cachedPath = _imageCache[imageUrl];

    if (cachedPath != null && File(cachedPath).existsSync()) {
      // nếu đã crop và lưu tạm -> dùng file local
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

    // nếu chưa có cache, bắt đầu preload (không block)
    if (!_processingImages.contains(imageUrl)) preloadImage(imageUrl);

    if (imageUrl.isEmpty) {
      return _buildErrorImage();
    }

    // mặc định hiển thị qua mạng (Image.network)
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

  // Hiển thị khung lỗi khi ảnh không load được
  Widget _buildErrorImage() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[200],
      child: Icon(Icons.broken_image, size: 36, color: Colors.grey),
    );
  }

  // Tính tổng tiền hàng (dùng dữ liệu orderItems + quantities)
  int calculateBaseTotal() {
    int total = 0;
    orderItems.forEach((key, value) {
      try {
        var food = foodShow.fromJson(value); // chuyển JSON -> model
        int price = int.tryParse(food.gia ?? "0") ?? 0;
        int qty =
            quantities[key] ??
            (int.tryParse(value['soluong']?.toString() ?? '') ?? 1);
        total += price * qty;
      } catch (e) {
        debugPrint('calculateBaseTotal error: $e');
      }
    });
    return total;
  }

  // Nút chọn tab (Cửa hàng / Người dùng) tái sử dụng từ Message
  Widget buildTabButton(String label, bool isShop, Color color) {
    bool isActive = isShopSelected == isShop;

    return GestureDetector(
      onTap: () {
        setState(() {
          isShopSelected = isShop;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  // Hàm an toàn để hiển thị ảnh món: chấp nhận url hoặc path local
  Widget _buildFoodImageSafeOrderItem(String imageUrl) {
    const double imgSize = 70;
    imageUrl = (imageUrl ?? '').toString();
    if (imageUrl.isEmpty) {
      // nếu không có ảnh -> placeholder
      return Container(
        width: imgSize,
        height: imgSize,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.fastfood, color: Colors.grey),
      );
    }
    if (imageUrl.startsWith('http')) {
      // ảnh từ URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: imgSize,
          height: imgSize,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: imgSize,
            height: imgSize,
            color: Colors.grey[200],
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }
    try {
      // hoặc đường dẫn file local
      final f = File(imageUrl);
      if (f.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            f,
            width: imgSize,
            height: imgSize,
            fit: BoxFit.cover,
          ),
        );
      }
    } catch (_) {}
    // fallback chung
    return Container(
      width: imgSize,
      height: imgSize,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  // --- Rating dialog: khi người dùng bấm "Đã nhận" sẽ bật dialog đánh giá ---
  void _showRatingDialog() {
    int _rating = 5; // mặc định 5 sao
    final TextEditingController _noteController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // không đóng bằng chạm ngoài
      builder: (ctx) {
        // StatefulBuilder để cập nhật trạng thái _rating trong dialog
        return StatefulBuilder(
          builder: (ctx2, setState2) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  SizedBox(width: 8),
                  Text('Đánh giá đơn hàng', textAlign: TextAlign.center),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Bạn cho cửa hàng mấy sao?'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final idx = i + 1;
                      return IconButton(
                        onPressed: () {
                          setState2(() {
                            _rating = idx; // cập nhật sao
                          });
                        },
                        icon: Icon(
                          idx <= _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Gửi nhận xét (tuỳ chọn)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Khi huỷ: đóng dialog và cho phép bấm lại nút Đã nhận
                    Navigator.pop(ctx);
                    setState(() {
                      _isbutton = true; // enable lại nút
                    });
                  },
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final note = _noteController.text.trim();
                    // TODO: nếu có backend, gọi API gửi rating ở đây
                    Navigator.pop(ctx); // đóng dialog
                    // Hiện snackbar cảm ơn
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cảm ơn bạn đã đánh giá $_rating sao${note.isNotEmpty ? ' — \"$note\"' : ''}.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // enable button và chuyển về Home (người dùng mong muốn)
                    setState(() {
                      _isbutton = true;
                    });
                    navigateToPage(Routers.home);
                  },
                  child: Text('Gửi'),
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
    const primaryColor = Color.fromRGBO(245, 203, 88, 1);
    const accentColor = Color.fromRGBO(233, 83, 34, 1);

    // compute totals (KHÔNG gọi setState trong build)
    final baseTotal = calculateBaseTotal();
    final shippingFee = 50000; // phí vận chuyển cố định
    const serviceFee = 700; // phí dịch vụ cứng
    grandTotal = baseTotal + shippingFee + serviceFee; // cập nhật biến

    int totalItems = 0;
    quantities.forEach((k, q) => totalItems += q);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => navigateToPage(Routers.home),
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
        title: Text(
          "Đơn hàng",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top: Tabs (Cửa hàng / Người dùng)
          Container(
            color: primaryColor,
            padding: const EdgeInsets.only(bottom: 10, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTabButton("Cửa hàng", true, accentColor),
                const SizedBox(width: 10),
                buildTabButton("Người dùng", false, accentColor),
              ],
            ),
          ),

          // Main content (Orders). Danh sách món + thông tin thanh toán
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Orders list card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          for (var i = 0; i < orderItems.length; i++)
                            _buildOrderItem(i.toString()),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Payment details
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: accentColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Chi tiết thanh toán",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildPriceRow(
                            "Tổng tiền hàng ($totalItems món)",
                            baseTotal,
                          ),
                          SizedBox(height: 10),
                          _buildPriceRow("Phí vận chuyển", shippingFee),
                          SizedBox(height: 10),
                          _buildPriceRow("Phí dịch vụ", serviceFee),
                          SizedBox(height: 16),
                          Divider(height: 1, thickness: 1),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tổng thanh toán",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${NumberFormat("#,###", "vi").format(grandTotal)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Bottom action (Giao hàng / Đặt hàng or Đã nhận -> rating)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tổng thanh toán",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "đ${NumberFormat("#,###", "vi").format(grandTotal)}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 180,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_isbutton) return; // nếu đang xử lý thì ignore
                            setState(() {
                              _isbutton = false; // disable button ngay
                            });

                            if (!isShopSelected) {
                              // Người dùng: khi bấm "Đã nhận" -> show rating dialog
                              _showRatingDialog();
                            } else {
                              // Cửa hàng: xử lý GIAO HÀNG (mô phỏng)
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.local_shipping,
                                        color: Colors.blue,
                                        size: 28,
                                      ),
                                      SizedBox(width: 12),
                                      Text("Đang giao hàng"),
                                    ],
                                  ),
                                  content: Text(
                                    "Bạn vừa đánh dấu đơn là đang giao. Khi người dùng nhận hàng, họ sẽ bấm 'Đã nhận' để đánh giá.",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        setState(() {
                                          _isbutton = true; // enable lại
                                        });
                                      },
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            isShopSelected ? "Giao hàng" : "Đã nhận",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
    );
  }

  // Xây dựng 1 dòng item hiển thị trong danh sách đơn hàng
  Widget _buildOrderItem(String key) {
    final item = orderItems.containsKey(key) ? orderItems[key] : null;
    if (item == null) return SizedBox.shrink();

    final imageUrl = (item['anh'] ?? '').toString();
    final ten = (item['ten'] ?? '-').toString();
    final gia = int.tryParse(item['gia']?.toString() ?? '0') ?? 0;
    final soluong = int.tryParse(item['soluong']?.toString() ?? '1') ?? 1;

    // đảm bảo quantities có giá trị mặc định
    quantities[key] = quantities[key] ?? soluong;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildFoodImageSafeOrderItem(imageUrl), // ảnh món
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ten,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "đ${NumberFormat("#,###", "vi").format(gia)}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE95322),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "x$soluong",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper hiển thị 1 hàng label - amount
  Widget _buildPriceRow(String label, int amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          "${amount < 0 ? '-' : ''}đ${NumberFormat("#,###", "vi").format(amount.abs())}",
          style: TextStyle(
            fontSize: 14,
            color: isDiscount ? Colors.green[700] : Colors.grey[800],
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
