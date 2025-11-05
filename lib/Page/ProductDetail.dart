import 'package:flutter/material.dart';
import '../model/product_show.dart';

class ProductDetail extends StatefulWidget {
  final ProductShow product;
  const ProductDetail({super.key, required this.product});
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
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
                "Add on ingredients",
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
