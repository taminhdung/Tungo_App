import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Routers.dart';

class ChatDetail extends StatefulWidget {
  final String name;
  final String avatarUrl;

  const ChatDetail({super.key, required this.name, required this.avatarUrl});

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> chatMessages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChatHistory();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  String get chatKey => "chat_${widget.name}";

  Future<void> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedData = prefs.getString(chatKey);

      if (savedData != null) {
        setState(() {
          chatMessages = List<Map<String, dynamic>>.from(jsonDecode(savedData));
          isLoading = false;
        });
      } else {
        // Tạo tin nhắn chào mừng mặc định
        createWelcomeMessages();
      }

      scrollToBottom();
    } catch (e) {
      debugPrint("Lỗi load chat: $e");
      createWelcomeMessages();
    }
  }

  void createWelcomeMessages() {
    setState(() {
      chatMessages = [
        {
          "text":
              "Xin chào Chủ Nhân Nguyễn Dương! Hãy để lại inbox nếu cần hỗ trợ nhé, Anh Nhi sẽ quay lại phản hồi sớm nhất.",
          "isMe": false,
        },
        {"text": "Để nạp thẻ: pay.zing.vn/mobile/omg", "isMe": false},
        {
          "text":
              "Để gửi yêu cầu xử lý lỗi: hotro.zing.vn/guithongtinyeucau_submit",
          "isMe": false,
        },
        {"text": "Bắt đầu", "isMe": false},
      ];
      isLoading = false;
    });
    saveChatHistory();
  }

  Future<void> saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(chatKey, jsonEncode(chatMessages));
    } catch (e) {
      debugPrint("Lỗi save chat: $e");
    }
  }

  void sendMessage() {
    String text = messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      chatMessages.add({"text": text, "isMe": true});
      messageController.clear();
    });

    saveChatHistory();
    scrollToBottom(delay: 100);
  }

  void scrollToBottom({int delay = 0}) {
    Future.delayed(Duration(milliseconds: delay), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryYellow = Color.fromRGBO(245, 203, 88, 1);
    const primaryOrange = Color.fromRGBO(233, 83, 34, 1);

    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: buildAppBar(primaryYellow, primaryOrange),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Chat messages
            Expanded(
              child: isLoading ? buildLoadingState() : buildMessagesList(),
            ),

            // Input box
            buildMessageInput(primaryOrange),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar(Color bgColor, Color iconColor) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      toolbarHeight: 130,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_new, color: iconColor),
      ),
      title: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.avatarUrl),
            radius: 25,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 6),
          Text(
            widget.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget buildMessagesList() {
    if (chatMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Chưa có tin nhắn",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: chatMessages.length,
      itemBuilder: (context, index) {
        final message = chatMessages[index];
        return buildMessageBubble(text: message["text"], isMe: message["isMe"]);
      },
    );
  }

  Widget buildMessageBubble({required String text, required bool isMe}) {
    const yellowColor = Color.fromRGBO(245, 203, 88, 1);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          // Avatar cho tin nhắn của người khác
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(widget.avatarUrl),
                backgroundColor: Colors.grey[300],
              ),
            ),

          // Bubble tin nhắn
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: isMe ? yellowColor : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 12),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageInput(Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: "Aa",
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: iconColor),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
