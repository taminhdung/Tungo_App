import 'package:flutter/material.dart';
import 'package:tungo_application/Page/Message.dart';
import '../Routers.dart';
import 'Me.dart';
import '../Service.dart';

class Notification extends StatefulWidget {
  const Notification({super.key});
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Service service = Service();
  List<dynamic>? notification_list;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await get_notification_list();
  }

  void open_page_me() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void move_page(String path) {
    Navigator.pushReplacementNamed(context, path);
  }

  Future<void> get_notification_list() async {
    final resurt = await service.getnotification();
    setState(() {
      notification_list = resurt;
    });
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
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => move_page(Routers.home),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(233, 83, 34, 1),
          ),
        ),
        title: Text(
          "Thông báo",
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
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: notification_list?[0]?.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final msg = notification_list?[0]['message${index}'];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(233, 83, 34, 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  msg.toString().toLowerCase().contains(
                                        "1 đơn hàng",
                                      )
                                      ? Icons.receipt_long
                                      : msg.toString().toLowerCase().contains(
                                              "thanh toán đơn hàng",
                                            ) ||
                                            msg
                                                .toString()
                                                .toLowerCase()
                                                .contains("thanh toán")
                                      ? Icons.money_outlined
                                      : msg.toString().toLowerCase().contains(
                                          "thêm món ăn",
                                        )
                                      ? Icons.fastfood_rounded
                                      : Icons.settings,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  notification_list?[0]['message${index}'] ??
                                      "",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
            currentIndex: 3,
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
                activeIcon: Icon(Icons.shopping_bag),
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
