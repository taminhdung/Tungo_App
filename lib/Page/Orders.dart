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

class Orders extends StatefulWidget {
  const Orders({super.key});
  State<Orders> createState() => _OrdersState();
}

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

class _OrdersState extends State<Orders>  with WidgetsBindingObserver{
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Service service = Service();
  Map<String, dynamic> orderItems = {};
  Map<String, dynamic> voucherItems = {};
  Map<String, int> quantities = {};
  Map<String, String> _imageCache = {};
  Set<String> _processingImages = {};
  int selectedDiscount = 0;
  int grandTotal = 0;
  String mota_voucher = "";
  bool _isbutton = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await loadOrderData();
    await loadOrdervoucher();
  }

  Future<void> loadOrderData() async {
    final result = await service.get_order_pay();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_item = {};
    for (int i = 0; i < data.length; i++) {
      map_item[i.toString()] = data[i];
    }
    setState(() {
      orderItems = Map.from(map_item);
    });
  }

  Future<void> loadOrdervoucher() async {
    final result = await service.getVoucherList();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_item = {};
    for (int i = 0; i < data.length; i++) {
      map_item[i.toString()] = data[i];
    }
    setState(() {
      voucherItems = Map.from(map_item);
    });
  }

  void navigateToPage(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  Future<String?> getCroppedImage(String imageUrl) async {
    if (imageUrl.isEmpty) return null;

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
    const double imgSize = 70;
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
      width: 70,
      height: 70,
      color: Colors.grey[200],
      child: Icon(Icons.broken_image, size: 36, color: Colors.grey),
    );
  }

  int calculateBaseTotal() {
    int total = 0;

    orderItems.forEach((key, value) {
      var food = foodShow.fromJson(value);
      int price = int.tryParse(food.gia ?? "0") ?? 0;
      int qty = quantities[key] ?? 1;
      total += price * qty;
    });

    return total;
  }

  void _showDiscountDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // nếu không có voucher
        if (voucherItems.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Không có mã giảm giá", style: TextStyle(fontSize: 16)),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Đóng"),
                ),
              ],
            ),
          );
        }

        // chuẩn bị danh sách key
        final keys = voucherItems.keys.toList();

        return Container(
          height: 800,
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Chọn mã giảm giá",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    final k = keys[index];
                    final v = voucherItems[k] as Map<String, dynamic>? ?? {};
                    final title = (v['ten'] ?? '').toString();
                    final mota = (v['mota'] ?? '').toString();
                    final image = (v['anh'] ?? '').toString();
                    // cố gắng parse số % trong chuỗi, nếu không có -> 0
                    final match = RegExp(r'(\d+)\s*%').firstMatch(title);
                    final int amount = match != null
                        ? int.tryParse(match.group(1)!) ?? 0
                        : (v['amount'] is int
                              ? v['amount'] as int
                              : int.tryParse(v['amount']?.toString() ?? '') ??
                                    0);
                    return _buildDiscountOption(
                      ctx,
                      title,
                      mota,
                      image,
                      amount,
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiscountOption(
    BuildContext ctx,
    String title,
    String mota,
    String image,
    int amount,
    int index,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          if (selectedDiscount == amount)
            selectedDiscount = 0;
          else
            selectedDiscount = amount;
          mota_voucher = mota;
        });
        Navigator.pop(ctx);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedDiscount == amount
                ? Color(0xFFE95322)
                : Colors.grey.shade300,
            width: selectedDiscount == amount ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedDiscount == amount
              ? Color(0xFFFFEBEE)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE95322).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(image, width: 50, height: 50),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    mota,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    amount > 0 ? "Giảm $amount%" : "Giảm 0",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFE95322),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedDiscount == amount)
              Icon(Icons.check_circle, color: Color(0xFFE95322), size: 28)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromRGBO(245, 203, 88, 1);
    const accentColor = Color.fromRGBO(233, 83, 34, 1);
    int baseTotal = 0;
    int shippingFee = 0;
    int serviceFee = 700; // Phí dịch vụ nền tảng
    final discount = selectedDiscount;
    // Tính tổng thanh toán
    if (mota_voucher == "Mặt hàng") {
      setState(() {
        baseTotal = int.parse(
          (calculateBaseTotal() - ((calculateBaseTotal() * discount) / 100))
              .toString()
              .split(".")[0],
        );
        shippingFee = 50000;
      });
    } else {
      setState(() {
        shippingFee = int.parse(
          (50000 - (50000 * discount / 100)).toString().split(".")[0],
        );
        baseTotal = calculateBaseTotal();
      });
    }
    grandTotal = baseTotal + shippingFee + serviceFee;
    // Tính tổng số món
    int totalItems = 0;
    quantities.forEach((key, qty) {
      totalItems += qty;
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => navigateToPage(Routers.shoppingcart),
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
        title: Text(
          "Thanh toán",
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
                    // Danh sách món ăn
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

                    // Đơn vị vận chuyển
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
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF00BFA5).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.delivery_dining,
                                  color: Color(0xFF00BFA5),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Đơn vị vận chuyển",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00BFA5),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Divider(height: 1),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tungo đội",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Giao hàng trong 2-4 giờ",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (mota_voucher == "Vận chuyển" &&
                                      discount > 0)
                                    Text(
                                      "đ${NumberFormat("#,###", "vi").format(50000)}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  Text(
                                    "đ${NumberFormat("#,###", "vi").format(shippingFee)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          mota_voucher == "Vận chuyển" &&
                                              discount > 0
                                          ? Color(0xFF00BFA5)
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Mã giảm giá
                    if (discount > 0)
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showDiscountDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE95322).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.local_offer,
                                      color: Color(0xFFE95322),
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Mã giảm giá",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Giảm đ${NumberFormat("#,###", "vi").format(discount)}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFE95322),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFFE95322),
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showDiscountDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE95322).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.local_offer,
                                      color: Color(0xFFE95322),
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Chọn mã giảm giá",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: 16),

                    // Chi tiết thanh toán
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
                          if (discount > 0) ...[
                            SizedBox(height: 10),
                            _buildPriceRow1(
                              "Giảm giá",
                              -discount,
                              isDiscount: true,
                            ),
                          ],
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
                                "đ${NumberFormat("#,###", "vi").format(grandTotal)}",
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

                    // Phương thức thanh toán
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
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.payments_outlined,
                              color: accentColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Phương thức thanh toán",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Thanh toán khi nhận hàng",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // Nút đặt hàng
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
                            if (_isbutton) {
                              // Hiển thị dialog xác nhận
                              _isbutton=false;
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
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 28,
                                      ),
                                      SizedBox(width: 12),
                                      Text("Đặt hàng thành công!"),
                                    ],
                                  ),
                                  content: Text(
                                    "Đơn hàng của bạn đã được xác nhận.\nChúng tôi sẽ giao hàng trong 2-4 giờ.",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _isbutton=true;
                                        navigateToPage(Routers.home);
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
                            "Đặt Hàng",
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

  Widget _buildOrderItem(String key) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          buildFoodImage(orderItems[key]['anh']),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderItems[key]['ten'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "đ${NumberFormat("#,###", "vi").format(int.parse(orderItems[key]['gia']))}",
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
              "x${orderItems[key]['soluong']}",
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

  Widget _buildPriceRow(String label, int amount, {bool isDiscount = false}) {
    const accentColor = Color.fromRGBO(233, 83, 34, 1);

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

  Widget _buildPriceRow1(String label, int amount, {bool isDiscount = false}) {
    const accentColor = Color.fromRGBO(233, 83, 34, 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          "${amount < 0 ? '-' : ''}${NumberFormat("#,###", "vi").format(amount.abs())}%",
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
