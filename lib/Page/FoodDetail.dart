import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/food_show.dart';
import '../Service.dart';
import '../Routers.dart';
import 'Message.dart'; // <-- thêm import để chuyển "Chat ngay"

class FoodDetail extends StatefulWidget {
  final foodShow Food;
  const FoodDetail({super.key, required this.Food});
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> with WidgetsBindingObserver {
  int quantity = 1;
  Service service = Service();
  static final Map<String, String> _optimizedCache = {};

  @override
  void initState() {
    super.initState();

    _maybeOptimizeImage(widget.Food.anh);
  }

  Future<void> _maybeOptimizeImage(String? url) async {
    try {
      if (url == null || url.isEmpty) return;

      final cached = _optimizedCache[url];
      if (cached != null && await File(cached).exists()) return;

      final path = await _optimizeImageToTemp(url);
      if (path != null) {
        _optimizedCache[url] = path;
      }
    } catch (e) {
      debugPrint('Background optimize image error: $e');
    }
  }

  Future<String?> _optimizeImageToTemp(String url) async {
    try {
      final uri = Uri.parse(url);
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return null;
      final Uint8List bytes = resp.bodyBytes;

      final Uint8List optimized = await compute<Uint8List, Uint8List>(
        _resizeBytesIsolate,
        bytes,
      );

      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/opt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath);
      await outFile.writeAsBytes(optimized);
      return outPath;
    } catch (e) {
      debugPrint('Optimize image failed for $url: $e');
      return null;
    }
  }

  static Uint8List _resizeBytesIsolate(Uint8List inputBytes) {
    final img.Image? original = img.decodeImage(inputBytes);
    if (original == null) {
      throw Exception('Không thể decode ảnh.');
    }

    const int maxWidth = 1080;
    img.Image processed = original;

    if (original.width > maxWidth) {
      final int newHeight = ((maxWidth * original.height) / original.width)
          .round();
      processed = img.copyResize(original, width: maxWidth, height: newHeight);
    }

    final List<int> jpg = img.encodeJpg(processed, quality: 85);
    return Uint8List.fromList(jpg);
  }

  Future<void> add_order(foodShow p) async {
    final prefs = await SharedPreferences.getInstance();
    if (p.useruid.toString() == prefs.getString('uid')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không thể thêm sản phẩm của chính mình"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final flag = await service.add_order(
      p.id,
      p.anh,
      p.ten,
      int.parse(
        "${int.parse(p.gia) - ((int.parse(p.gia) * int.parse(p.giamgia)) ~/ 100)}",
      ),
      quantity,
    );
    if (!flag) {
      print('Thêm giỏ hàng thất bại.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Thêm giỏ hàng thất bại."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Thêm giỏ hàng thành công"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacementNamed(context, Routers.home);
  }

  Widget _buildSingleComment({
    required String avatarUrl,
    required String username,
    required int rating, // 1..5
    required String comment,
  }) {
    // build star row
    final stars = Row(
      children: List.generate(5, (i) {
        if (i < rating) {
          return const Icon(Icons.star, size: 14, color: Colors.redAccent);
        } else {
          return const Icon(Icons.star_border, size: 14, color: Colors.grey);
        }
      }),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey[200],
            backgroundImage: (avatarUrl.isNotEmpty)
                ? NetworkImage(avatarUrl)
                : null,
            child: (avatarUrl.isEmpty)
                ? const Icon(Icons.person_outline, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name + stars
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    stars,
                  ],
                ),
                const SizedBox(height: 6),
                // comment text
                Text(comment, style: TextStyle(color: Colors.grey[800])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.Food;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 203, 88, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 203, 88, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.ten,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  const SizedBox(width: 3),
                  Text(
                    p.sao,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  p.anh,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    "đ${NumberFormat.decimalPattern('vi').format((int.parse("${int.parse(p.gia) - ((int.parse(p.gia) * int.parse(p.giamgia)) ~/ 100)}")))}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 5),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (quantity > 1) setState(() => quantity--);
                    },
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => quantity++),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "đ${NumberFormat.decimalPattern('vi').format(int.parse(p.gia))}",
                    style: const TextStyle(
                      fontSize: 15,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.grey, // màu gạch (tuỳ chọn)
                      decorationThickness: 2,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "-${p.giamgia}%",
                    style: const TextStyle(fontSize: 15, color: Colors.orange),
                  ),
                ],
              ),

              // ====== BẮT ĐẦU CHÈN SHOP HEADER (logo + tên + chat) ======
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Logo tròn (placeholder nếu không có link)
                    ClipOval(
                      child: Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[200],
                        child: const Icon(Icons.store, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tên và trạng thái
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tungo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
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

                    // Nút Chat ngay
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
                          style: TextStyle(
                            color: Color.fromRGBO(233, 83, 34, 1),
                          ),
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

              // ====== KẾT THÚC CHÈN SHOP HEADER ======
              const Divider(),
              const SizedBox(height: 15),
              const Text(
                "Mô tả",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsetsGeometry.only(bottom: 16),
                child: Text(p.mota, style: TextStyle(color: Colors.grey[700])),
              ),

              // ====== BẮT ĐẦU CHÈN PHẦN BÌNH LUẬN (avatar, tên, sao, nội dung) ======
              const SizedBox(height: 8),
              const Text(
                "Bình luận",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Ví dụ 1 bình luận (theo ảnh bạn gửi)
              _buildSingleComment(
                avatarUrl:
                    '', // nếu có url avatar thì đặt vào, để trống sẽ hiển thị icon mặc định
                username: 'niaucdu',
                rating: 5,
                comment:
                    'so với lần trước giao hàng ko đc lần này thì shop giao hàng rất nhanh đóng gói cẩn thận ko bị bóp méo hàng đẹp ok lắm nên mua nha mn cảm ơn shop lần sau sẽ qua ủng hộ tiếp',
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 16),

              // ====== KẾT THÚC CHÈN PHẦN BÌNH LUẬN ======
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Thêm vào giỏ hàng",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(233, 83, 34, 1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    await add_order(p);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
