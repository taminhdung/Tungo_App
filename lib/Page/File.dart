import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Routers.dart';
import '../Service.dart';
import 'dart:io' as io;
import 'package:intl/intl.dart';

class File extends StatefulWidget {
  const File({super.key});
  @override
  State<File> createState() => _FileState();
}

class _FileState extends State<File> {
  Service service = Service();
  static Map<String, dynamic> info = {};
  static DateTime date_value = DateTime(1990, 1, 1);
  io.File? image_path;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await loadinformation();
  }

  void move_page(String path) {
    Navigator.pushReplacementNamed(context, path);
  }

  void open_page_me() {}

  Future<void> loadinformation() async {
    final data = await service.getinformation() as Map<String, dynamic>?;
    setState(() {
      info = data!;
      int second_value = int.parse(
        info['timestamp'].toString().split(",")[0].split("=")[1],
      );
      int nanosecond_value = int.parse(
        info['timestamp'].toString().split(",")[1].split("=")[1].split(")")[0],
      );
      Timestamp ts = Timestamp(second_value, nanosecond_value);
      date_value = ts.toDate();
    });
  }

  Future<void> update_user_information(
    link_image_old,
    ten,
    sodienthoai,
    ngaysinh,
    gioitinh,
    diachi,
  ) async {
    String? link_image = link_image_old;
    if (image_path != null) {
      final flag0 = await service.DeleteImageuser(link_image_old);
      if (flag0 == "") {
        print('Xoá ảnh thất bại.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xoá ảnh thất bại."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      String? link_image1 = await service.uploadImageuser(image_path!);
      setState(() {
        link_image = link_image1.toString();
      });
      if (link_image == "") {
        print('tải ảnh lên thất bại.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("tải ảnh lên thất bại."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    final flag1 = await service.update_user(
      link_image,
      ten,
      sodienthoai,
      ngaysinh,
      gioitinh,
      diachi,
    );

    if (!flag1) {
      print('Lưu dữ liệu thất bại');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lưu dữ liệu thất bại"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lưu thành công"), backgroundColor: Colors.green),
    );
    move_page(Routers.file);
  }

  String? avatarUrl = info['avatar'].toString();
  final TextEditingController nameController = TextEditingController(
    text: info['name'],
  );
  final TextEditingController emailController = TextEditingController(
    text: info['email'],
  );
  final TextEditingController phoneController = TextEditingController(
    text: info['phonenumber'],
  );
  final TextEditingController birthController = TextEditingController(
    text: info['birth'],
  );
  final TextEditingController sexController = TextEditingController(
    text: info['sex'],
  );
  final TextEditingController addressController = TextEditingController(
    text: info['address'],
  );

  final TextEditingController timestampController = TextEditingController(
    text: '${date_value.toString()}',
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
                            child: image_path != null
                                ? Image.file(
                                    image_path!,
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
                                  )
                                : (avatarUrl == null || avatarUrl!.isEmpty)
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
                            onTap: () async {
                              final io.File? path = await service.getImage();
                              setState(() {
                                image_path = path;
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
                    _buildYellowField1(emailController),
                    const SizedBox(height: 20),
                    _buildLabel("Số điện thoại"),
                    _buildYellowField(phoneController),
                    const SizedBox(height: 20),
                    _buildLabel("Ngày sinh"),
                    _buildYellowField(birthController),
                    const SizedBox(height: 20),
                    _buildLabel("Giới tính"),
                    _buildYellowField(sexController),
                    const SizedBox(height: 20),
                    _buildLabel("Địa chỉ"),
                    _buildYellowField(addressController),
                    const SizedBox(height: 20),
                    _buildLabel("Ngày đăng ký"),
                    _buildYellowField1(timestampController),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final phone = phoneController.text.trim();
                          final birth = birthController.text.trim();
                          final sex = sexController.text.trim();
                          final address = sexController.text.trim();
                          if (name.isEmpty ||
                              phone.isEmpty ||
                              birth.isEmpty ||
                              sex.isEmpty ||
                              address.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Vui lòng nhập đầy đủ thông tin trước khi lưu.",
                                ),
                              ),
                            );
                            return;
                          }

                          if (!RegExp(r'^\S+(?:\s+\S+){1,}$').hasMatch(name)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Tên không hợp lệ."),
                              ),
                            );
                            return;
                          }

                          if (!RegExp(
                            r'^(?:\+84|84|0)(3|5|7|8|9)[0-9]{8}$',
                          ).hasMatch(phone)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Số điện thoại không hợp lệ."),
                              ),
                            );
                            return;
                          }
                          try {
                            final min_date = DateTime.parse(
                              DateFormat(
                                'yyyy-MM-dd',
                              ).format(DateTime(1900, 01, 01)),
                            );
                            final max_date = DateTime.parse(
                              DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            );
                            final birth_date = DateTime.parse(
                              DateFormat('yyyy-MM-dd').format(
                                DateTime(
                                  int.parse(birth.split("-")[0]),
                                  int.parse(birth.split("-")[1]),
                                  int.parse(birth.split("-")[2]),
                                ),
                              ),
                            );
                            if (!(birth_date.isAfter(min_date) &&
                                birth_date.isBefore(max_date))) {
                              throw new Error();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Ngày sinh không hợp lệ không hợp lệ.\nTheo định dạng Năm-Tháng-Ngày",
                                ),
                              ),
                            );
                          }
                          if (!RegExp(r'^(Nam|Nữ|nam|nữ)$').hasMatch(sex)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Giới tính không hợp lệ."),
                              ),
                            );
                            return;
                          }
                          print(image_path);
                          print(info['avatar']);
                          await update_user_information(
                            info['avatar'],
                            name,
                            phone,
                            birth,
                            sex,
                            address,
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

  Widget _buildYellowField1(TextEditingController controller) {
    return TextField(
      controller: controller,
      enabled: false,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        color: Colors.grey,
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
