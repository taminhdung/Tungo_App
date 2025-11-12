// lib/Page/payment_qr.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Routers.dart';
import '../Service.dart';

class PaymentQR extends StatefulWidget {
  const PaymentQR({super.key});
  State<PaymentQR> createState() => _PaymentQRState();
}

class _PaymentQRState extends State<PaymentQR> with WidgetsBindingObserver {
  Service service = Service();
  VoidCallback? onFinish;
  static String nameorder = "";
  static String nameorder1 = "";
  static Map<String, dynamic> orderItems = {};
  //https://www.vietqr.io/danh-sach-api/link-tao-ma-nhanh/
  String qrImageUrl = "";
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await loadOrderData1();
  }

  void navigateToPage(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> loadOrderData1() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await service.get_order_pay1();
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      result ?? [],
    );
    Map<String, dynamic> map_item = {};
    for (int i = 0; i < data.length; i++) {
      map_item[i.toString()] = data[i];
    }
    setState(() {
      orderItems = Map.from(map_item[prefs.getString('order_id')]);
    });
    nameorder = await removeDiacritics(orderItems["nameorder"]);
    nameorder1 = await removeDiacritics1(orderItems["nameorder"]);
    setState(() {
      qrImageUrl =
          "https://img.vietqr.io/image/970422-12752306022015-qr_only.png?amount=${orderItems["totalorder"]}&addInfo=${nameorder}}&accountName=NGUYEN%20MINH%20DUONG";
    });
  }

  String removeDiacritics(String str) {
    const withDia =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨ'
        'ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮ'
        'ỲÝỴỶỸĐ';
    const withoutDia =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiii'
        'ooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIII'
        'OOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    str = str.replaceAll(" ", "%20");
    return str;
  }

  String removeDiacritics1(String str) {
    const withDia =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨ'
        'ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮ'
        'ỲÝỴỶỸĐ';
    const withoutDia =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiii'
        'ooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIII'
        'OOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color.fromRGBO(233, 83, 34, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán bằng QR"),
        backgroundColor: const Color.fromRGBO(245, 203, 88, 1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Placeholder cho QR
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Quét mã QR để thanh toán",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: qrImageUrl != ""
                          ? Image.network(qrImageUrl, fit: BoxFit.cover)
                          : Container(),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Tên ngân hàng: MB Bank-Ngân hàng quân đội",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Chủ sở hữu: NGUYEN MINH DUONG",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Số tài khoản: 12752306022015",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Số tiền: ${NumberFormat("#,###", "vi").format(int.parse(orderItems['totalorder']))}₫",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Nội dung: $nameorder1",
                    style: TextStyle(fontSize: 15, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Thanh toán thành công"),
                          content: const Text(
                            "Cảm ơn bạn, giao dịch đã hoàn tất.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                // gọi callback nếu có, hoặc quay về Home
                                if (onFinish != null) {
                                  onFinish!();
                                } else {
                                  navigateToPage(Routers.home);
                                }
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      "Tôi đã thanh toán (Hoàn tất)",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => navigateToPage(Routers.orders),
                  child: const Text("Quay lại"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
