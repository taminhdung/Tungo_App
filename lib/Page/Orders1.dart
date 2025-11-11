// lib/Page/Orders.dart
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
import 'Message.dart'; // để chuyển "Chat ngay"

/// Orders1: màn danh sách gọn (mỗi order 1 card)
class Orders1 extends StatefulWidget {
  const Orders1({super.key});
  @override
  State<Orders1> createState() => _OrdersState1();
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

class _OrdersState1 extends State<Orders1> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Service service = Service();

  Map<String, dynamic> orderItems = {}; // giữ nếu cần (index based)
  Map<String, int> quantities = {};

  // groupedOrders: orderId -> list of items
  Map<String, List<Map<String, dynamic>>> groupedOrders = {};

  Map<String, String> _imageCache = {};
  Set<String> _processingImages = {};

  int grandTotal = 0;
  bool _isbutton = true;
  String _paymentMethod = 'cash';

  bool isShopSelected = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await loadOrderData();
  }

  Future<void> loadOrderData() async {
    try {
      final result = await service.get_order_pay();
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        result ?? [],
      );

      // keep original mapping (optional)
      Map<String, dynamic> map_item = {};
      for (int i = 0; i < data.length; i++) {
        map_item[i.toString()] = data[i];
        quantities[i.toString()] =
            int.tryParse(data[i]['soluong']?.toString() ?? '') ?? 1;
      }

      // --- Group items into orders ---
      groupedOrders.clear();
      // Nếu API có tên trường order id khác, thêm vào list này
      const orderIdKeyCandidates = [
        'order_id',
        'madon',
        'orderId',
        'ma_don',
        'don_id',
      ];
      for (var item in data) {
        String orderId = 'single';
        for (var key in orderIdKeyCandidates) {
          if (item.containsKey(key)) {
            final v = item[key]?.toString();
            if (v != null && v.isNotEmpty) {
              orderId = v;
              break;
            }
          }
        }
        groupedOrders.putIfAbsent(orderId, () => []).add(item);
      }

      setState(() {
        orderItems = Map.from(map_item);
      });
    } catch (e) {
      debugPrint('loadOrderData error: $e');
    }
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

  Widget _buildFoodImageSafeOrderItem(String imageUrl) {
    const double imgSize = 70;
    imageUrl = (imageUrl ?? '').toString();
    if (imageUrl.isEmpty) {
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

  int calculateBaseTotal() {
    int total = 0;
    // sum all grouped orders
    groupedOrders.forEach((orderId, items) {
      for (var it in items) {
        try {
          final price = int.tryParse(it['gia']?.toString() ?? '0') ?? 0;
          final qty = int.tryParse(it['soluong']?.toString() ?? '1') ?? 1;
          total += price * qty;
        } catch (e) {
          debugPrint('calculateBaseTotal item error: $e');
        }
      }
    });
    return total;
  }

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

  // Build compact card for a grouped order (multiple items combined into one order)
  Widget _buildCompactOrderCardGroup(
    String orderId,
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty) return SizedBox.shrink();

    // names joined by comma
    final names = items.map((it) => (it['ten'] ?? '-').toString()).join(', ');
    // total price
    int total = 0;
    for (var it in items) {
      final price = int.tryParse(it['gia']?.toString() ?? '0') ?? 0;
      final qty = int.tryParse(it['soluong']?.toString() ?? '1') ?? 1;
      total += price * qty;
    }

    const double iconSize = 70;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailPage(
              item: {
                'items': items,
                'order_id': orderId,
                // optionally pass shop info if available:
                'shop_logo':
                    items.firstWhere(
                      (e) => e.containsKey('shop_logo'),
                      orElse: () => {},
                    )['shop_logo'] ??
                    '',
                'shop_name':
                    items.firstWhere(
                      (e) => e.containsKey('shop_name'),
                      orElse: () => {},
                    )['shop_name'] ??
                    '',
                'shop_subtitle':
                    items.firstWhere(
                      (e) => e.containsKey('shop_subtitle'),
                      orElse: () => {},
                    )['shop_subtitle'] ??
                    '',
                // note: you can pass 'voucher_text' here if you want to show text discount
                // 'voucher_text': 'Voucher XYZ50 - Giảm 50.000đ',
              },
              totalForThisOrder: total,
              isShopSelected: isShopSelected,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 36,
                color: Color(0xFFE95322),
              ), // icon thay thumbnail
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    names,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Text(
                    "đ${NumberFormat('#,###', 'vi').format(total)}",
                    style: TextStyle(color: Color(0xFFE95322)),
                  ),
                ],
              ),
            ),
            // bỏ hiển thị số lượng theo yêu cầu
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromRGBO(245, 203, 88, 1);
    const accentColor = Color.fromRGBO(233, 83, 34, 1);

    final baseTotal = calculateBaseTotal();
    final shippingFee = 50000;
    const serviceFee = 700;
    grandTotal = baseTotal + shippingFee + serviceFee;

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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // render grouped orders (1 card per order)
                  for (var entry in groupedOrders.entries)
                    _buildCompactOrderCardGroup(entry.key, entry.value),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // BỎ bottom bar ở trang list theo yêu cầu (không hiển thị tổng + nút giao)
        ],
      ),
    );
  }

  void _showRatingDialog() {
    int _rating = 5;
    final TextEditingController _noteController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState2) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text('Đánh giá đơn hàng'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Bạn cho cửa hàng mấy sao?'),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final idx = i + 1;
                      return IconButton(
                        onPressed: () => setState2(() => _rating = idx),
                        icon: Icon(
                          idx <= _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Gửi nhận xét (tuỳ chọn)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _isbutton = true;
                    });
                  },
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final note = _noteController.text.trim();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cảm ơn bạn đã đánh giá $_rating sao${note.isNotEmpty ? ' — \"$note\"' : ''}.',
                        ),
                      ),
                    );
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
}

//// OrderDetailPage: hiển thị danh sách món trong 1 order, payment details,
// shop header (logo + name) và nút "Chat ngay" ở cạnh phải của khối shop.
class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic>
  item; // expects { 'items': [...], optional shop fields }
  final int totalForThisOrder;
  final bool isShopSelected;

  const OrderDetailPage({
    super.key,
    required this.item,
    required this.totalForThisOrder,
    this.isShopSelected = false,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isbutton = true;

  void _showRatingDialog() {
    int _rating = 5;
    final TextEditingController _noteController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
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
                        onPressed: () => setState2(() => _rating = idx),
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
                    Navigator.pop(ctx);
                    setState(() {
                      _isbutton = true;
                    });
                  },
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final note = _noteController.text.trim();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cảm ơn bạn đã đánh giá $_rating sao${note.isNotEmpty ? ' — \"$note\"' : ''}.',
                        ),
                      ),
                    );
                    setState(() {
                      _isbutton = true;
                    });
                    Navigator.pushReplacementNamed(context, Routers.home);
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
    const accentColor = Color.fromRGBO(233, 83, 34, 1);

    // items from passed item (support both old single item and grouped list)
    final items = (widget.item['items'] is List)
        ? List<Map<String, dynamic>>.from(widget.item['items'])
        : [widget.item];

    // total (if passed use it, otherwise compute)
    int total = widget.totalForThisOrder;
    if (total == 0) {
      total = 0;
      for (var it in items) {
        final price = int.tryParse(it['gia']?.toString() ?? '0') ?? 0;
        final qty = int.tryParse(it['soluong']?.toString() ?? '1') ?? 1;
        total += price * qty;
      }
    }

    final shippingFee = 50000;
    const serviceFee = 700;

    // --- SIMPLE discount text (no API logic) ---
    // If you want to show a discount text, pass 'voucher_text' or 'discount_text' in widget.item map.
    final discountText =
        (widget.item['voucher_text'] ?? widget.item['discount_text'] ?? '')
            .toString()
            .trim();

    // grand total here DOES NOT subtract discountText (per your request)
    final grandTotal = total + shippingFee + serviceFee;

    // shop info (if provided in widget.item)
    final shopLogo = (widget.item['shop_logo'] ?? '').toString();
    final shopName = (widget.item['shop_name'] ?? 'Tungo').toString();
    final shopSubtitle = (widget.item['shop_subtitle'] ?? 'Online gần đây')
        .toString();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text("Chi tiết đơn hàng", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
        child: Column(
          children: [
            // card: show first item thumbnail + name (but list below shows all items)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  // show thumbnail of first item if exists
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        (items.isNotEmpty &&
                            (items.first['anh'] ?? '').toString().isNotEmpty)
                        ? Image.network(
                            items.first['anh'].toString(),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[200],
                              child: Icon(Icons.broken_image),
                            ),
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: Icon(Icons.fastfood),
                          ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // show joined names or first name
                        Text(
                          items
                              .map((e) => (e['ten'] ?? '-').toString())
                              .join(', '),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "đ${NumberFormat('#,###', 'vi').format(total)}",
                          style: TextStyle(color: accentColor),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: accentColor),
                      SizedBox(width: 8),
                      Text(
                        "Chi tiết thanh toán",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _priceRow("Tổng tiền hàng (${items.length} món)", total),
                  SizedBox(height: 8),
                  _priceRow("Phí vận chuyển", shippingFee),
                  SizedBox(height: 8),
                  _priceRow("Phí dịch vụ", serviceFee),
                  SizedBox(height: 8),
                  _priceRow("Giảm giá", serviceFee),

                  // --- SHOW SIMPLE discount TEXT if provided (no API, no deduction) ---
                  if (discountText.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Giảm giá",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            discountText,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tổng thanh toán",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "đ${NumberFormat('#,###', 'vi').format(grandTotal)}",
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Shop header (logo + name) placed BELOW payment details with Chat button on the right
            // Shop header (logo + name) placed BELOW payment details with Chat button on the right
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Logo tròn
                  ClipOval(
                    child: shopLogo.isNotEmpty
                        ? Image.network(
                            shopLogo,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 48,
                                  height: 48,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.store, color: Colors.grey),
                                ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[200],
                            child: Icon(Icons.store, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 10),

                  // Tên và trạng thái (như hình Shopee)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên shop
                        Text(
                          'Tungo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Trạng thái online / vị trí
                        Text(
                          'Online gần đây',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nút chat ngay
                  SizedBox(
                    height: 40,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Message()),
                        );
                      },
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Color.fromRGBO(233, 83, 34, 1),
                      ),
                      label: const Text(
                        "Chat ngay",
                        style: TextStyle(color: Color.fromRGBO(233, 83, 34, 1)),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: Colors.grey.shade200),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Optionally show the list of items in the order (each row)
            Container(
              // small list in white card
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: items.map((it) {
                  final name = (it['ten'] ?? '-').toString();
                  final price = int.tryParse(it['gia']?.toString() ?? '0') ?? 0;
                  final imgUrl = (it['anh'] ?? '').toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (imgUrl.isNotEmpty)
                              ? Image.network(
                                  imgUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.fastfood),
                                ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          "đ${NumberFormat('#,###', 'vi').format(price)}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(child: Container()),

            // bottom action: giữ nguyên hành vi cũ (shop / user)
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tổng thanh toán",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "đ${NumberFormat('#,###', 'vi').format(grandTotal)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 150,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_isbutton) return;
                        setState(() {
                          _isbutton = false;
                        });

                        if (widget.isShopSelected) {
                          // Cửa hàng: hiện dialog "Đang giao hàng"
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
                                      _isbutton = true;
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
                        } else {
                          // Người dùng: hiện dialog đánh giá
                          _showRatingDialog();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        widget.isShopSelected ? "Giao hàng" : "Đã nhận",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text("đ${NumberFormat('#,###', 'vi').format(amount)}"),
      ],
    );
  }
}
