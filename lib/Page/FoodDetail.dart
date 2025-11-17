import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/food_show.dart';
import '../Service.dart';
import '../Routers.dart'; // <-- thêm import để chuyển "Chat ngay"
import 'chatdetail.dart';

class FoodDetail extends StatefulWidget {
  const FoodDetail({super.key});
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> with WidgetsBindingObserver {
  int quantity = 1;
  Service service = Service();
  Map<String, dynamic> info = {};
  String login_text = "";
  Map<String, dynamic> item = {};
  String uid = "";
  bool _loading = true;
  String? _errorMessage;
  String? userUid = "";
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await get_Item();
      await loadinformation();
    } catch (e, st) {
      debugPrint('Error in load: $e\n$st');
      setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> get_Item() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await service.getlist();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_item = {};
    final storedFoodId = prefs.getString("foodid");
    if (storedFoodId != null && storedFoodId.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        final cur = data[i];
        if (cur['id'] == storedFoodId) {
          map_item["item0"] = cur;
          break;
        }
      }
    }
    setState(() {
      item = Map.from(map_item);
    });
  }

  Future<void> loadinformation() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid')!;
    // đảm bảo item có dữ liệu trước khi gọi service.getinformation1
    if (item.isEmpty || item['item0'] == null) {
      setState(() {
        _errorMessage = 'Không có dữ liệu món ăn';
      });
      return;
    }

    userUid = item['item0']['useruid'] as String?;
    if (userUid == null || userUid!.isEmpty) {
      setState(() {
        _errorMessage = 'Không có thông tin người bán';
      });
      return;
    }

    final data =
        await service.getinformation1(userUid!) as Map<String, dynamic>?;
    if (data == null) {
      setState(() {
        _errorMessage = 'Không lấy được thông tin người bán';
      });
      return;
    }

    // xử lý loginat an toàn (có thể null hoặc string)
    String computedLoginText = 'Không có thông tin';
    final rawLogin = data['loginat'];
    DateTime? login;
    if (rawLogin is Timestamp) {
      login = rawLogin.toDate();
    } else if (rawLogin is String) {
      login = DateTime.tryParse(rawLogin);
    } else {
      login = null;
    }

    if (login != null) {
      final now = DateTime.now();
      final diff = now.difference(login);
      if (diff.inSeconds < 60) {
        computedLoginText = '${diff.inSeconds} giây trước';
      } else if (diff.inMinutes < 60) {
        computedLoginText = '${diff.inMinutes} phút trước';
      } else if (diff.inHours < 24) {
        computedLoginText = '${diff.inHours} giờ trước';
      } else if (diff.inDays < 7) {
        computedLoginText = '${diff.inDays} ngày trước';
      } else {
        computedLoginText = DateFormat('dd/MM/yyyy').format(login);
      }
    }

    setState(() {
      info = data;
      login_text = computedLoginText;
      _errorMessage = null;
    });
  }

  // sửa add_order để chấp nhận Map (an toàn hơn khi bạn lấy dữ liệu trực tiếp từ service.getlist)
  Future<void> add_order(Map<String, dynamic> p) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUid = prefs.getString('uid') ?? '';

    final sellerUid = (p['useruid'] is String)
        ? p['useruid'] as String
        : (p['useruid']?.toString() ?? '');

    if (sellerUid == currentUid && currentUid.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Không thể thêm sản phẩm của chính mình"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Lấy giá an toàn
    final rawGia = p['gia']?.toString() ?? '0';
    final rawGiamGia = p['giamgia']?.toString() ?? '0';
    int giaInt = int.tryParse(rawGia) ?? 0;
    int giamGiaInt = int.tryParse(rawGiamGia) ?? 0;
    final finalPrice = giaInt - ((giaInt * giamGiaInt) ~/ 100);

    final flag = await service.add_order(
      p['id']?.toString() ?? '',
      p['anh']?.toString() ?? '',
      p['ten']?.toString() ?? '',
      finalPrice,
      quantity,
    );

    if (!flag) {
      debugPrint('Thêm giỏ hàng thất bại.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thêm giỏ hàng thất bại."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
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
    // nếu đang load -> hiển thị spinner
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // nếu có lỗi -> hiển thị thông báo
    if (_errorMessage != null) {
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
            onPressed: () =>
                Navigator.pushReplacementNamed(context, Routers.showallfood),
          ),
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    // Nếu item rỗng (không tìm thấy) -> hiển thị placeholder
    final Map<String, dynamic>? item0 = (item['item0'] is Map<String, dynamic>)
        ? Map<String, dynamic>.from(item['item0'])
        : null;
    if (item0 == null) {
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
            onPressed: () =>
                Navigator.pushReplacementNamed(context, Routers.showallfood),
          ),
        ),
        body: const Center(child: Text('Không tìm thấy món ăn')),
      );
    }

    // Safely extract fields with defaults
    final name = item0['ten']?.toString() ?? 'Tên đồ ăn';
    final sao = item0['sao']?.toString() ?? '0.0';
    final anh = item0['anh']?.toString() ?? '';
    final mota = item0['mota']?.toString() ?? '';
    final rawGia = item0['gia']?.toString() ?? '0';
    final rawGiamGia = item0['giamgia']?.toString() ?? '0';
    final giaInt = int.tryParse(rawGia) ?? 0;
    final giamGiaInt = int.tryParse(rawGiamGia) ?? 0;
    final finalPriceInt = giaInt - ((giaInt * giamGiaInt) ~/ 100);

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
          onPressed: () =>
              Navigator.pushReplacementNamed(context, Routers.showallfood),
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
                name,
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
                    sao,
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
                child: (anh.isNotEmpty)
                    ? Image.network(
                        anh,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          width: double.infinity,
                          height: 220,
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        width: double.infinity,
                        height: 220,
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    "đ${NumberFormat.decimalPattern('vi').format(finalPriceInt)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 5),
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
                    giamGiaInt == 0
                        ? ""
                        : "đ${NumberFormat.decimalPattern('vi').format(giaInt)}",
                    style: const TextStyle(
                      fontSize: 15,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.grey,
                      decorationThickness: 2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    giamGiaInt == 0 ? "" : "-${giamGiaInt}%",
                    style: const TextStyle(fontSize: 15, color: Colors.orange),
                  ),
                ],
              ),
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
                        child:
                            (info['avatar'] is String &&
                                (info['avatar'] as String).isNotEmpty)
                            ? Image.network(
                                info['avatar'],
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.person_outline),
                              )
                            : const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tên và trạng thái
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (info['name']?.toString() ?? 'Tên shop'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Online ${login_text.isNotEmpty ? login_text : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: uid.toString() != userUid.toString()
                          ? TextButton.icon(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await service.create_message(
                                  prefs.getString("uid1"),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetail(
                                      name: info['name']?.toString() ?? "",
                                      avatarUrl:
                                          info['avatar']?.toString() ?? "",
                                      uid: userUid ?? "",
                                    ),
                                  ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 15),
              const Text(
                "Mô tả",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(mota, style: TextStyle(color: Colors.grey[700])),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 120),
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
                    await add_order(item0);
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
