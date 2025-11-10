import 'package:flutter/material.dart';
import '../Routers.dart';
import 'ChatDetail.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message>  with WidgetsBindingObserver {
  bool isShopSelected = true;

  // Fake data để test
  final List<Map<String, String>> messages = [
    {
      "name": "Minh Dương",
      "message": "Tin nhắn và cuộc gọi được bảo mật đầu cuối.",
      "avatar":
          "https://images.unsplash.com/photo-1603415526960-f7e0328c63b1?w=800&q=80",
    },
    {
      "name": "Ngọc Anh",
      "message": "Cảm ơn bạn đã đặt hàng hôm nay!",
      "avatar":
          "https://images.unsplash.com/photo-1607746882042-944635dfe10e?w=800&q=80",
    },
    {
      "name": "Tấn Phát",
      "message": "Đơn hàng của bạn đang được chuẩn bị.",
      "avatar":
          "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=800&q=80",
    },
  ];

  void navigateBack() {
    Navigator.pushReplacementNamed(context, Routers.home);
  }

  void openChatDetail(String name, String avatarUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetail(name: name, avatarUrl: avatarUrl),
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
          Container(
            color: primaryYellow,
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTabButton("Cửa hàng", true, primaryOrange),
                const SizedBox(width: 10),
                buildTabButton("Người dùng", false, primaryOrange),
              ],
            ),
          ),

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
              child: messages.isEmpty ? buildEmptyState() : buildMessageList(),
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
      itemCount: messages.length,
      padding: const EdgeInsets.all(10),
      separatorBuilder: (context, index) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final msg = messages[index];
        return buildMessageItem(
          name: msg["name"]!,
          message: msg["message"]!,
          avatarUrl: msg["avatar"]!,
        );
      },
    );
  }

  Widget buildMessageItem({
    required String name,
    required String message,
    required String avatarUrl,
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
      onTap: () => openChatDetail(name, avatarUrl),
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
