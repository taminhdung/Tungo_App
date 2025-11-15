import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Routers.dart';
import 'ChatDetail.dart';
import '../Service.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> with WidgetsBindingObserver {
  bool isShopSelected = true;
  Service service = Service();
  List<String> uid_list = [];
  List<Map<String,dynamic>> information = [];
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await load_message_info();
    await load_information_user();
  }

  Future<void> load_information_user() async {
    List<Object?> information1 = [];
    for (int i = 0; i < uid_list.length; i++) {
      final resurt = await service.getinformation1(uid_list[i].toString());
      information1.add(resurt);
    }

    setState(() {
      information = information1.whereType<Map<String, dynamic>>().toList();
    });
  }

  Future<void> load_message_info() async {
    final resurt = await service.get_message();
    uid_list = resurt as List<String>;
  }
  // Fake data để test

  void navigateBack() {
    Navigator.pushReplacementNamed(context, Routers.home);
  }

  void openChatDetail(String name, String avatarUrl,String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetail(name: name, avatarUrl: avatarUrl,uid:uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryYellow = Color.fromRGBO(245, 203, 88, 1);
    const primaryOrange = Color.fromRGBO(233, 83, 34, 1);

    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        toolbarHeight: 90,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: navigateBack,
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryOrange),
        ),
      ),
      body: Column(
        children: [
          // Tab chọn giữa Cửa hàng và Người dùng

          // List tin nhắn
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: information.isEmpty
                  ? buildEmptyState()
                  : buildMessageList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabButton(String label, bool isShop, Color color) {
    bool isActive = isShopSelected == isShop;

    return GestureDetector(
      onTap: () {
        setState(() {
          isShopSelected = isShop;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    return ListView.separated(
      itemCount: information.length,
      padding: const EdgeInsets.all(10),
      separatorBuilder: (context, index) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        String computedLoginText = 'Không có thông tin';
        final rawLogin = information[index]['loginat'];
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
        return buildMessageItem(
          name: information[index]['name'],
          message: computedLoginText,
          avatarUrl:information[index]['avatar'],
          id: index.toString()
        );
      },
    );
  }

  Widget buildMessageItem({
    required String name,
    required String message,
    required String avatarUrl,
    required String id,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: buildAvatar(avatarUrl),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.black54, fontSize: 13),
      ),
      onTap: () => openChatDetail(name, avatarUrl,(uid_list[int.parse(id)]).toString()),
    );
  }

  Widget buildAvatar(String url) {
    return ClipOval(
      child: Image.network(
        url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey, size: 28),
          );
        },
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Chưa có tin nhắn nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Các cuộc trò chuyện của bạn sẽ hiển thị ở đây",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
