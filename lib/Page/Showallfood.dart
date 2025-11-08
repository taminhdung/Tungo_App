import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../Routers.dart';
import '../Service.dart';
import '../model/food_show.dart';
import 'Me.dart';
import 'FoodDetail.dart';

class Showallfood extends StatefulWidget {
  const Showallfood({super.key});
  State<Showallfood> createState() => _ShowallfoodState();
}

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

  final List<int> jpg = img.encodeJpg(cropped, quality: 90);
  return Uint8List.fromList(jpg);
}

class _ShowallfoodState extends State<Showallfood> {
  final service = Service();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> item = {};
  Map<String, dynamic> item1 = {};
  Map<String, dynamic> item2 = {};
  Map<String, dynamic> item3 = {};

  final Map<String, String> _croppedCache = {};
  final Map<String, String> _localOverride = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  int index_bottom_button = 0;

  void loadData() async {
    await get_Item();
    await get_Item_bestseller();
    await get_Item_sale();
  }

  void move_page(String path) {
    Navigator.pushReplacementNamed(context, path);
  }

  void open_page_me() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> get_Item() async {
    final result = await service.getlist();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_item = {};
    for (int i = 0; i < data.length; i++) {
      map_item["item$i"] = data[i];
    }
    setState(() {
      item = Map.from(map_item);
      item1 = Map.from(item);
    });
  }

  Future<void> get_Item_bestseller() async {
    List<Map<String, dynamic>> listItem = item.values
        .cast<Map<String, dynamic>>()
        .toList();

    listItem.sort((a, b) {
      int sa = int.tryParse(a['sohangdaban'].toString()) ?? 0;
      int sb = int.tryParse(b['sohangdaban'].toString()) ?? 0;
      return sb.compareTo(sa);
    });

    Map<String, dynamic> sortedItem = {};
    for (int i = 0; i < listItem.length; i++) {
      sortedItem["item$i"] = listItem[i];
    }

    setState(() {
      item2 = sortedItem;
    });
  }

  Future<void> get_Item_sale() async {
    item3.clear();
    int count = -1;
    for (int i = 0; i < item.length; i++) {
      int sold = int.tryParse(item["item$i"]['giamgia'].toString()) ?? 0;
      if (sold > 0) {
        count++;
        item3["item$count"] = item["item$i"];
      }
    }
  }

  Future<String?> _getCroppedImagePath(String url) async {
    try {
      if (url.isEmpty) return null;

      final cached = _croppedCache[url];
      if (cached != null) {
        final f = File(cached);
        if (await f.exists()) return cached;
        _croppedCache.remove(url);
      }

      final uri = Uri.parse(url);
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        return null;
      }
      final bytes = resp.bodyBytes;

      final Uint8List croppedBytes = await compute<Uint8List, Uint8List>(
        _cropBytesIsolate,
        bytes,
      );

      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath);
      await outFile.writeAsBytes(croppedBytes);

      _croppedCache[url] = outPath;
      return outPath;
    } catch (e) {
      debugPrint('Auto crop (network) error for $url: $e');
      return null;
    }
  }

  Widget _buildCroppedImageWidget(
    String url, {
    double width = 110,
    double height = 110,
  }) {
    try {
      final local = _localOverride[url] ?? _croppedCache[url];
      if (local != null) {
        final f = File(local);
        if (f.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: Image.file(
              f,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          );
        }
      }

      if (!_croppedCache.containsKey(url)) {
        _getCroppedImagePath(url)
            .then((path) {
              if (path != null) {
                _croppedCache[url] = path;
                _localOverride[url] = path;
                if (mounted) setState(() {});
              }
            })
            .catchError((e) {
              debugPrint('Background crop failed for $url: $e');
            });
      }

      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: SizedBox(
          width: width,
          height: height,
          child: Image.network(
            url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: width,
                height: height,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error building cropped widget for $url: $e');
      return SizedBox(
        width: width,
        height: height,
        child: Image.network(
          url,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      key: _scaffoldKey,
      endDrawer: Me(),
      backgroundColor: Color.fromRGBO(245, 203, 88, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 150,
        leading: IconButton(
          onPressed: () => move_page(Routers.home),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
          ),
        ),
        title: Text(
          "Danh sách sản phẩm",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        actions: const <Widget>[SizedBox(width: 0)],
      ),
      body: Container(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {
                            item.clear();
                            setState(() {
                              item = Map.from(item1);
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 2,
                            ),
                            backgroundColor: Color.fromRGBO(233, 83, 34, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Tất cả",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            item.clear();
                            setState(() {
                              item = Map.from(item2);
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 2,
                            ),
                            backgroundColor: Color.fromRGBO(233, 83, 34, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Bán chạy",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            item.clear();
                            setState(() {
                              item = Map.from(item3);
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 2,
                            ),
                            backgroundColor: Color.fromRGBO(233, 83, 34, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Giảm giá",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true, // ⚡ Bắt buộc: tự co chiều cao
                      physics:
                          NeverScrollableScrollPhysics(), // ⚡ Vô hiệu cuộn riêng
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 15,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: item.length < 5 ? 5 : item.length,
                      itemBuilder: (context, index) {
                        if (item["item$index"] == null) {
                          return SizedBox();
                        }
                        final foods = foodShow.fromJson(item["item${index}"]);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodDetail(Food: foods),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
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
                                foods.anh.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                          left: 30,
                                          right: 30,
                                        ),
                                        child: SizedBox(
                                          width: 110, // chiều ngang
                                          height: 110, // chiều dọc
                                          child: CircularProgressIndicator(
                                            strokeWidth: 10, // độ dày
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: 110,
                                        height: 110,
                                        child: _buildCroppedImageWidget(
                                          foods.anh,
                                          width: 110,
                                          height: 110,
                                        ),
                                      ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 10),
                                                Text(
                                                  foods.ten,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  "đ${foods.gia}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                                SizedBox(height: 7),
                                                Text(
                                                  "Giảm giá ${foods.giamgia}%",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 14,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(width: 1),
                                                    Text(
                                                      foods.diachi,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 76),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          foods.sao,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                      ],
                                    ),
                                    SizedBox(height: 7),
                                    Text(
                                      "Đã bán ${foods.sohangdaban}",
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.red,
            currentIndex: index_bottom_button,
            onTap: (index) {
              setState(() {
                index_bottom_button = index;
              });
              switch (index) {
                case 0:
                  move_page(Routers.home);
                  break;
                case 1:
                  move_page(Routers.voucher);
                  break;
                case 2:
                  move_page(Routers.shop);
                  break;
                case 3:
                  move_page(Routers.notification);
                  break;
                case 4:
                  open_page_me();
                  break;
              }
            },
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Trang chủ",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.discount_outlined),
                activeIcon: Icon(Icons.discount),
                label: "Mã giải giá",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.favorite),
                label: "Cửa hàng",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none),
                activeIcon: Icon(Icons.notifications),
                label: "Thông báo",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined),
                activeIcon: Icon(Icons.person),
                label: "Tôi",
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
