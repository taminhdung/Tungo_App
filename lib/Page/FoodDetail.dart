import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../model/food_show.dart';

class FoodDetail extends StatefulWidget {
  final foodShow Food;
  const FoodDetail({super.key, required this.Food});
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  int quantity = 1;

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
                    "đ${p.gia}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
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
              const Divider(),
              const Text(
                "Mô tả",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                "Cơm ngon kèm theo đùi gà lớn, giá rẻ, hấp dẫn, được nhiều khách yêu thích.",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              const Text(
                "Tuỳ chọn thêm",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Column(
                children: const [
                  ListTile(title: Text("Đùi nhỏ"), trailing: Text("đ30.000")),
                  ListTile(title: Text("Đùi lớn"), trailing: Text("đ60.000")),
                  ListTile(title: Text("Ức gà lớn"), trailing: Text("đ60.000")),
                  ListTile(title: Text("Ức gà nhỏ"), trailing: Text("đ30.000")),
                ],
              ),
              const SizedBox(height: 20),
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã thêm vào giỏ hàng")),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
