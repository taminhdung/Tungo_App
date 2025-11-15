import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Routers.dart';
import '../Service.dart';
import 'dart:io' as io;

class File extends StatefulWidget {
  const File({super.key});
  @override
  State<File> createState() => _FileState();
}

class _FileState extends State<File> with WidgetsBindingObserver {
  Service service = Service();
  static Map<String, dynamic> info1 = {};
  static DateTime date_value = DateTime(1990, 1, 1);
  io.File? image_path;
  bool _isbutton = true;
  final Map<String, String> bankMap = {
    "VietinBank": "970415",
    "Vietcombank": "970436",
    "BIDV": "970418",
    "Agribank": "970405",
    "OCB": "970448",
    "MBBank": "970422",
    "Techcombank": "970407",
    "ACB": "970416",
    "VPBank": "970432",
    "TPBank": "970423",
    "Sacombank": "970403",
    "HDBank": "970437",
    "VietCapitalBank": "970454",
    "SCB": "970429",
    "VIB": "970441",
    "SHB": "970443",
    "Eximbank": "970431",
    "MSB": "970426",
    "CAKE": "546034",
    "Ubank": "546035",
    "ViettelMoney": "971005",
    "Timo": "963388",
    "VNPTMoney": "971011",
    "SaigonBank": "970400",
    "BacABank": "970409",
    "MoMo": "971025",
    "PVcomBank Pay": "971133",
    "PVcomBank": "970412",
    "MBV": "970414",
    "NCB": "970419",
    "ShinhanBank": "970424",
    "ABBANK": "970425",
    "VietABank": "970427",
    "NamABank": "970428",
    "PGBank": "970430",
    "VietBank": "970433",
    "BaoVietBank": "970438",
    "SeABank": "970440",
    "COOPBANK": "970446",
    "LPBank": "970449",
    "KienLongBank": "970452",
    "KBank": "668888",
    "MAFC": "977777",
    "HongLeong": "970442",
    "KEBHANAHN": "970467",
    "KEBHanaHCM": "970466",
    "Citibank": "533948",
    "CBBank": "970444",
    "CIMB": "422589",
    "DBSBank": "796500",
    "Vikki": "970406",
    "VBSP": "999888",
    "GPBank": "970408",
    "KookminHCM": "970463",
    "KookminHN": "970462",
    "Woori": "970457",
    "VRB": "970421",
    "HSBC": "458761",
    "IBKHN": "970455",
    "IBKHCM": "970456",
    "IndovinaBank": "970434",
    "UnitedOverseas": "970458",
    "Nonghyup": "801011",
    "StandardChartered": "970410",
    "PublicBank": "970439",
  };

  String? avatarUrl = info1['avatar'].toString();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController banknameController = TextEditingController();
  final TextEditingController banknumberController = TextEditingController();
  final TextEditingController ownernameController = TextEditingController();
  final TextEditingController timestampController = TextEditingController();

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
      info1 = data!;
      int second_value = int.parse(
        info1['createdAt'].toString().split(",")[0].split("=")[1],
      );
      int nanosecond_value = int.parse(
        info1['createdAt'].toString().split(",")[1].split("=")[1].split(")")[0],
      );
      Timestamp ts = Timestamp(second_value, nanosecond_value);
      date_value = ts.toDate();
      nameController.text = info1['name'].toString();
      emailController.text = info1['email'].toString();
      phoneController.text = info1['phonenumber'].toString();
      birthController.text = info1['birth'].toString();
      sexController.text = info1['sex'].toString();
      addressController.text = info1['address'].toString();
      banknameController.text = info1['bankname'].toString();
      banknumberController.text = info1['banknumber'].toString();
      ownernameController.text = info1['ownername'].toString();
      timestampController.text =date_value.toString();
    });
  }
  void _showwarningchangeinformation() {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // Không thể bấm ra ngoài để đóng
      enableDrag: false, // Không thể kéo xuống để đóng
      backgroundColor: Colors.transparent, // Giữ trong suốt để bo góc đẹp
      builder: (sheetContext) {
        return GestureDetector(
          // Chặn tap ra ngoài (click nền trong suốt)
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: WillPopScope(
            // Chặn nút Back vật lý trên Android
            onWillPop: () async => false,
            child: Container(
              margin: const EdgeInsets.only(top: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'Bạn có chắc chắn những thông tin này là chính xác?\nVì việc thay đổi này anh hưởng đến quá trình giao dịch của bạn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Xem lại',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                          if (_isbutton) {
                            _isbutton = false;
                            final name = nameController.text.trim();
                            final phone = phoneController.text.trim();
                            final birth = birthController.text.trim();
                            final sex = sexController.text.trim();
                            final address = addressController.text.trim();
                            final bankname = banknameController.text.trim();
                            final banknumber = banknumberController.text.trim();
                            final ownername = ownernameController.text.trim();
                            final bankcode = bankMap[bankname] ?? '';
                            if (name.isEmpty ||
                                phone.isEmpty ||
                                birth.isEmpty ||
                                sex.isEmpty ||
                                bankname.isEmpty ||
                                banknumber.isEmpty ||
                                ownername.isEmpty || 
                                bankcode.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Vui lòng nhập đầy đủ thông tin trước khi lưu.",
                                  ),
                                ),
                              );
                              _isbutton = true;
                              return;
                            }

                            if (!RegExp(
                              r'^\S+(?:\s+\S+){1,}$',
                            ).hasMatch(name)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Tên không hợp lệ."),
                                ),
                              );
                              _isbutton = true;
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
                              _isbutton = true;
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
                              _isbutton = true;
                            }
                            if (!RegExp(r'^(Nam|Nữ|nam|nữ)$').hasMatch(sex)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Giới tính không hợp lệ."),
                                ),
                              );
                              _isbutton = true;
                              return;
                            }
                            await update_user_information(
                              info1['avatar'],
                              name,
                              phone,
                              birth,
                              sex,
                              address,
                              bankname,
                              banknumber,
                              ownername,
                            );
                          }
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              233,
                              83,
                              34,
                              1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Chắc chắn',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Future<void> update_user_information(
    link_image_old,
    ten,
    sodienthoai,
    ngaysinh,
    gioitinh,
    diachi,
    tennganhang,
    sotaikhoan,
    tenchutaikhoan,
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
      tennganhang,
      sotaikhoan,
      tenchutaikhoan,
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
    _isbutton = true;
    move_page(Routers.file);
  }


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
                    _buildLabel("Tên ngân hàng ngân hàng"),
                    _buildDropdownBank(banknameController),
                    const SizedBox(height: 20),
                    _buildLabel("Số tài khoản ngân hàng"),
                    _buildYellowField(banknumberController),
                    const SizedBox(height: 20),
                    _buildLabel("Chủ tài khoản"),
                    _buildYellowField(ownernameController),
                    const SizedBox(height: 20),
                    _buildLabel("Ngày đăng ký"),
                    _buildYellowField1(timestampController),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {_showwarningchangeinformation();},
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

  Widget _buildDropdownBank(TextEditingController controller) {
  return DropdownButtonFormField<String>(
    value: controller.text.isNotEmpty ? controller.text : null,
    items: bankMap.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.key, // tên ngân hàng
        child: Text("${entry.key}"), // hiển thị tên + id
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        controller.text = value!;
      });
    },
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
    icon: const Icon(Icons.arrow_drop_down),
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      color: Colors.black,
    ),
  );
}

}
