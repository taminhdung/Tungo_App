import 'package:flutter/material.dart';
import '../Routers.dart';
import '../Service.dart';

class File extends StatefulWidget {
  const File({super.key});
  State<File> createState() => _FileState();
}

class _FileState extends State<File> {
  static Service service = Service();

  void move_page(String path) {
    Navigator.pushReplacementNamed(context, path);
  }

  void open_page_me() {}

  String? avatarUrl =
      "https://i.pinimg.com/originals/1f/d8/11/1fd8112a0a46b6f8c62c87c86f4f57ac.jpg";

  final TextEditingController nameController = TextEditingController(
    text: "nguyễn văn a",
  );
  final TextEditingController emailController = TextEditingController(
    text: "Example@Example.Com",
  );
  final TextEditingController birthController = TextEditingController(
    text: "07 / 01 / 2005",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "+123 567 89000",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 203, 88, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 150,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routers.home);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
          ),
        ),
        title: const Text(
          "Hồ sơ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[200],
                            child: (avatarUrl == null || avatarUrl!.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  )
                                : Image.network(
                                    avatarUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                avatarUrl =
                                    "https://cdn.xanhsm.com/2025/01/7f24de71-bun-rieu-quy-nhon-1.jpg";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(233, 83, 34, 1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildLabel("Họ và tên"),
                    _buildYellowField(nameController),
                    const SizedBox(height: 20),
                    _buildLabel("Email"),
                    _buildYellowField(emailController),
                    const SizedBox(height: 20),
                    _buildLabel("Ngày sinh"),
                    _buildYellowField(birthController),
                    const SizedBox(height: 20),
                    _buildLabel("Số điện thoại"),
                    _buildYellowField(phoneController),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final email = emailController.text.trim();
                          final birth = birthController.text.trim();
                          final phone = phoneController.text.trim();

                          if (name.isEmpty ||
                              email.isEmpty ||
                              birth.isEmpty ||
                              phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Vui lòng nhập đầy đủ thông tin trước khi lưu.",
                                ),
                              ),
                            );
                            return;
                          }

                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Email không hợp lệ."),
                              ),
                            );
                            return;
                          }

                          if (!RegExp(r'^[0-9\+\-\s]{9,}$').hasMatch(phone)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Số điện thoại không hợp lệ."),
                              ),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Lưu thay đổi thành công."),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(233, 83, 34, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          "Lưu",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 1,
            backgroundColor: Colors.red,
            onTap: (index) {
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
            items: const [
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
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildYellowField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFF2C5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
