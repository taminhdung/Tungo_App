// lib/Page/payment_qr.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Routers.dart';

class PaymentQR extends StatelessWidget {
  final int amount;
  final VoidCallback? onFinish;
  final String? qrImageUrl;

  const PaymentQR({
    super.key,
    required this.amount,
    this.onFinish,
    this.qrImageUrl,
  });

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
          const Text(
            "Quét mã QR để thanh toán",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text("Số tiền: đ${NumberFormat("#,###", "vi").format(amount)}"),
          const SizedBox(height: 24),
          // Placeholder cho QR
          Expanded(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: qrImageUrl != null
                    ? Image.network(qrImageUrl!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.qr_code, size: 80, color: Colors.grey),
                          SizedBox(height: 12),
                          Text("Mã QR (placeholder)"),
                        ],
                      ),
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
                      // TODO: nếu có API, gọi API xác nhận thanh toán ở đây
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
                                  Navigator.pushReplacementNamed(
                                    context,
                                    Routers.home,
                                  );
                                }
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Tôi đã thanh toán (Hoàn tất)"),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
