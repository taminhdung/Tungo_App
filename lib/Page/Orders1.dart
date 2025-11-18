// lib/Page/Orders.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../Routers.dart';
import 'package:intl/intl.dart';
import '../Service.dart';
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

  List<Map<String, dynamic>> orderItems1 = []; // giữ nếu cần (index based)
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
    await refreshData();
    await loadOrderData();
  }

  Future<void> refreshData() async {
    final result = await service.get_order_pay3();
    setState(() {
      orderItems1 = result as List<Map<String, dynamic>>;
    });
  }

  Future<void> loadOrderData() async {
    try {
      final result = [await service.get_order_pay2()];
      // Cẩn trọng: API có thể trả Map hoặc List; bạn đang bọc thêm một List nữa.
      // Nếu API trả dạng nested, bạn có thể cần điều chỉnh. Hiện giữ logic cũ của bạn.
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        result,
      );
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

  /// SỬA: hàm nhận **URL** trực tiếp (không lookup orderItems[imageUrl])
  Widget _buildFoodImageSafeOrderItem(String imageUrl, {double size = 70}) {
    final imgSize = size;
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
  Widget _buildCompactOrderCardGroup(int index) {
    const double iconSize = 70;
    return InkWell(
      onTap: () {
        Map<String, dynamic> order_loc = {};
        final list_key = orderItems["0"].keys;
        List<String> list_key1 = list_key.toList();
        int count = 0;
        for (var i in list_key1) {
          if (i.contains("order${index}")) {
            order_loc[count.toString()] = orderItems["0"][i];
            count += 1;
          }
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailPage(
              orderlist: order_loc,
              orderlist1: orderItems1,
              isShopSelected: isShopSelected,
              indexorder: index,
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
                    orderItems1[index]['nameorder']?.toString() ?? '',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Text(
                    "₫${orderItems1[index]['totalorder']?.toString() ?? ''}",
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
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 150,
        leading: IconButton(
          onPressed: () => navigateToPage(Routers.home),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
            size: 20,
          ),
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
      body: Container(
        color: Colors.grey[100],
        // padding bên ngoài để không chạm vào cạnh
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: RefreshIndicator(
          onRefresh: () async {
            await load();
          },
          child: Builder(
            builder: (context) {
              // chuyển map entries -> list để có index

              // nếu không có đơn hàng -> hiển thị trạng thái rỗng
              if (orderItems1.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 36),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text(
                            'Chưa có đơn hàng',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Kéo xuống để làm mới.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 200),
                  ],
                );
              }

              // có đơn hàng -> hiển thị list có index
              return ListView.builder(
                padding: EdgeInsets.only(top: 16, bottom: 24),
                itemCount: orderItems1.length,
                itemBuilder: (context, index) {
                  return Column(children: [_buildCompactOrderCardGroup(index)]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic>
  orderlist; // có thể là map index->item hoặc 1 order map
  final List<Map<String, dynamic>> orderlist1; // summary list (nếu cần)
  final bool isShopSelected;
  int indexorder;

  OrderDetailPage({
    super.key,
    required this.orderlist,
    required this.orderlist1,
    this.isShopSelected = false,
    required this.indexorder,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isbutton = true;
  bool _isPaid = true;
  Service service = Service();
  List<Map<String, dynamic>> _normalizeItems(dynamic raw) {
    // Return a list of item maps whatever the input shape is.
    if (raw == null) return [];
    try {
      if (raw is List) {
        // ensure each element is a Map<String,dynamic>
        return raw.map<Map<String, dynamic>>((e) {
          if (e is Map<String, dynamic>) return e;
          if (e is Map) return Map<String, dynamic>.from(e);
          return <String, dynamic>{};
        }).toList();
      } else if (raw is Map<String, dynamic> || raw is Map) {
        final m = raw as Map;
        // If it already contains 'items' List, use that
        if (m.containsKey('items') && m['items'] is List) {
          return (m['items'] as List).map<Map<String, dynamic>>((e) {
            if (e is Map<String, dynamic>) return e;
            if (e is Map) return Map<String, dynamic>.from(e);
            return <String, dynamic>{};
          }).toList();
        }
        // Otherwise, try take values that are Map (map_item style index->item)
        final values = m.values.where((v) => v is Map).toList();
        if (values.isNotEmpty) {
          return values.map<Map<String, dynamic>>((e) {
            if (e is Map<String, dynamic>) return e;
            return Map<String, dynamic>.from(e as Map);
          }).toList();
        }
        // fallback: treat the whole map as single item
        return [Map<String, dynamic>.from(m)];
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color.fromRGBO(233, 83, 34, 1);
    if (widget.orderlist1[widget.indexorder]['status'] == "Đã nhận hàng") {
      setState(() {
        _isPaid = false;
        _isbutton = false;
      });
    }
    // Normalize items from passed orderlist (safe for Map or List)
    final items = _normalizeItems(widget.orderlist);
    // compute total
    int total = 0;
    for (var it in items) {
      final price = int.tryParse(it['gia']?.toString() ?? '0') ?? 0;
      final qty = int.tryParse(it['soluong']?.toString() ?? '1') ?? 1;
      total += price * qty;
    }

    final shippingFee = 50000;
    const serviceFee = 700;

    // discount text: try to read from summary (orderlist1) or from first item
    String discountText = '';
    if (widget.orderlist is Map) {
      final m = widget.orderlist as Map;
      if (m.containsKey('voucher_text'))
        discountText = m['voucher_text']?.toString() ?? '';
      else if (m.containsKey('discount_text'))
        discountText = m['discount_text']?.toString() ?? '';
    }
    if (discountText.isEmpty && items.isNotEmpty) {
      discountText =
          (items.first['voucher_text'] ?? items.first['discount_text'] ?? '')
              .toString();
    }

    final grandTotal = total + shippingFee + serviceFee;

    // UI responsive grid columns
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (screenWidth < 360) crossAxisCount = 2;
    if (screenWidth >= 600) crossAxisCount = 4;

    // We'll use a fixed bottomNavigationBar so the bottom container is always fixed at bottom.
    // Keep the full internal content but make it scrollable with bottom padding to avoid overlap.
    final double bottomBarHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 150,
        elevation: 0,
        leading: IconButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, Routers.orders1),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
            size: 24,
          ),
        ),
        title: const Text(
          "Đơn hàng",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      // Body: scrollable content with extra bottom padding so it's not hidden by bottom bar.
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.fromLTRB(16, 18, 16, bottomBarHeight + 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 8),
              // Card: thumbnails & basic info
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid thumbnails (shrink wrapped)
                    if (items.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics:
                            NeverScrollableScrollPhysics(), // parent ListView chịu scroll
                        padding: EdgeInsets.zero,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey[200]),
                        itemCount: items.length,
                        itemBuilder: (context, idx) {
                          final it = items[idx];
                          final imgUrl = widget.orderlist[idx.toString()]['anh'];
                          final name = widget.orderlist[idx.toString()]['ten'];
                          final price = int.tryParse(
                            widget.orderlist[idx.toString()]['gia'],
                          );
                          final qty = widget.orderlist[idx.toString()]['soluong'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                // thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      imgUrl.isNotEmpty && imgUrl.startsWith('http')
                                          ? Image.network(
                                              imgUrl,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 56,
                                                height: 56,
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 56,
                                              height: 56,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.fastfood,
                                                color: Colors.grey,
                                              ),
                                            ),
                                ),

                                SizedBox(width: 12),

                                // name + price
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "đ${NumberFormat('#,###', 'vi').format(price)}",
                                        style: TextStyle(
                                          color: Color(0xFFE95322),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // qty badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'x$qty',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        height: 80,
                        alignment: Alignment.center,
                        child: Text(
                          'Không có món nào trong đơn',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
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
                    _priceRow1(
                      "Giảm giá",
                      int.parse(widget.orderlist1[widget.indexorder]['trigia']),
                    ),

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
                          "đ${NumberFormat('#,###', 'vi').format(int.parse(widget.orderlist1[widget.indexorder]['totalorder'].toString()))}",
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

              SizedBox(height: 16),
              // other content if any...
            ],
          ),
        ),
      ),

      // FIXED bottom area using bottomNavigationBar so it's always pinned at the bottom
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: bottomBarHeight,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Left: total info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tổng thanh toán",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "đ${NumberFormat("#,###", "vi").format(grandTotal)}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
                    ),
                  ],
                ),
              ),

              // Right: button
              SizedBox(
                width: 150,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_isbutton) return;
                    setState(() {
                      _isbutton = false;
                    });

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx2) => AlertDialog(
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
                            Text("Nhận hàng"),
                          ],
                        ),
                        content: Text(
                          "Bạn đã nhận hàng thành công, cảm ơn bạn đã sử dụng dịch vụ của chúng tôi.",
                          style: TextStyle(fontSize: 14),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              if (mounted) setState(() => _isbutton = true);
                            },
                            child: Text(
                              "Huỷ",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await service.receive_delivery(widget.indexorder);
                              _isPaid = !_isPaid;
                              Navigator.pop(context);
                              if (mounted) setState(() => _isbutton = false);
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _isPaid ? "Nhận hàng" : "Đã nhận",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _priceRow1(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text("${NumberFormat('#,###', 'vi').format(amount)}%"),
      ],
    );
  }
}
