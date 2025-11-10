import 'dart:math';

import 'package:flutter/material.dart';
import '../Routers.dart';

class Supports extends StatefulWidget {
  const Supports({super.key});
  State<Supports> createState() => _SupportsState();
}

class _SupportsState extends State<Supports>  with WidgetsBindingObserver {
  List<Map<String, String>> faqList = [
    {
      'question': "Làm Sao Tôi Có Thể Hoàn Lại Tiền?",
      'answer':
          "Hãy gửi video về lý do muốn trả hàng qua email, chúng tôi sẽ xem xét thông báo qua email để gửi, tiền của khách hàng sẽ được cập về tài khoản sau 30 ngày. Gọi email",
    },

    {
      'question': "Tài Khoản Tôi Đã Bị Khoá",
      'answer': "Hãy liên hệ với chúng tôi để kiểm tra lý do tài khoản bị khoá",
    },

    {
      'question': "Làm Sao Đổi Mật Khẩu Khi Không Truy ...",
      'answer':
          "Bạn có thể đặt lại mật khẩu bằng cách sử dụng tính năng quên mật khẩu",
    },

    {
      'question': "Tải Khoản Không Thể Truy Cập Được",
      'answer':
          "Vui lòng kiểm tra kết nối internet hoặc thử đăng xuất và đăng nhập lại",
    },

    {
      'question': "Tại Sao Tôi Không Thêm Mã Giảm Giá Vào...",
      'answer':
          "Mã giảm giá có thể đã hết hạn hoặc không áp dụng cho sản phẩm này",
    },

    {
      'question': "Tôi Quên Mật Tài Khoản Rồi",
      'answer': "Nhấn vào nút 'Quên mật khẩu' để đặt lại mật khẩu của bạn",
    },
  ];

  List<bool> isExpandedList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isExpandedList = List.filled(faqList.length, false);
  }

  void move_page(String path) {
    Navigator.pushReplacementNamed(context, path);
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      backgroundColor: Color.fromRGBO(245, 203, 88, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1),
        toolbarHeight: 150,
        leading: IconButton(
          onPressed: ()=>move_page(Routers.home),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
          ),
        ),
        title: Text(
          "Trợ giúp",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "FAQ",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Bạn gặp vấn đề gì?",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                          ),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: faqList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: ExpansionTile(
                          title: Text(
                            faqList[index]['question']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                faqList[index]['answer']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 180),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Tôi không bị các trường hợp trên. ",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () {
                          move_page(Routers.contact);
                        },
                        child: Text(
                          "Liên hệ",
                          style: TextStyle(
                            color: Color.fromRGBO(233, 83, 34, 1),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
