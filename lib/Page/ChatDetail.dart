import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service.dart';

class ChatDetail extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final String uid;

  const ChatDetail({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.uid,
  });

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> with WidgetsBindingObserver {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Service service = Service();
  StreamSubscription<Map<String, dynamic>?>? _sub;
  bool isLoading = true;
  Map<String, dynamic>? message_value;
  String? myUid; // lưu myUid 1 lần để tính isMe
  String? otherUid; // lưu myUid 1 lần để tính isMe

  @override
  void initState() {
    super.initState();
    // loadChatHistory();
    // Lấy myUid trước rồi mới load listen
    _loadAndListen();
  }

  Future<void> _loadAndListen() async {
    final prefs = await SharedPreferences.getInstance();
    myUid = prefs.getString('uid');
    await load_information_user();
  }

  Future<void> load() async {
    await load_information_user();
  }

  @override
  void dispose() {
    _sub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  String get chatKey => "chat_${widget.name}";

  // Listen realtime (giữ cấu trúc, nhưng subscribe thay vì .first)
  Future<void> load_information_user() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final myUidLocal = prefs.getString('uid').toString();
      otherUid = widget.uid;
      final stream = service.get_message1(otherUid!, myUidLocal);

      await _sub?.cancel();

      _sub = stream.listen(
        (resurt) {
          debugPrint('STREAM EVENT (ChatDetail): $resurt');

          setState(() {
            message_value = resurt != null
                ? Map<String, dynamic>.from(resurt)
                : null;
            isLoading = false;
          });

          // scroll tới cuối khi có data
          scrollToBottom(delay: 120);
        },
        onError: (e) {
          debugPrint('Stream error: $e');
          setState(() {
            isLoading = false;
          });
        },
      );
    } catch (e, st) {
      debugPrint('Error in load_information_user: $e\n$st');
      setState(() {
        message_value = null;
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage() async {
    String text = messageController.text.trim();
    await service.add_message(
      uid: myUid!,
      uid1: otherUid!,
      text: text,
    );
    // debug print an toàn
    if (message_value != null && message_value!['message0'] != null) {
      try {
        debugPrint(message_value!["message0"]['text'].toString());
      } catch (_) {}
    }

    if (text.isEmpty) return;
    setState(() {
      // dọn input (còn logic push message lên Firestore để service xử lý)
      messageController.clear();
    });

    // scroll sau khi gửi
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

  // parse message_value -> list và hiển thị
  Widget buildMessagesList() {
    if (message_value == null || message_value!.isEmpty) {
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

    // Parse Map thành list có thứ tự
    final List<Map<String, dynamic>> parsed = [];
    try {
      message_value!.forEach((k, v) {
        if (k is String && k.startsWith('message') && v is Map) {
          final idxStr = k.substring('message'.length);
          final idx = int.tryParse(idxStr) ?? 0;
          parsed.add({
            '_idx': idx,
            'key': k,
            'payload': Map<String, dynamic>.from(v),
          });
        }
      });
    } catch (e) {
      debugPrint('Error parsing message_value: $e');
    }

    if (parsed.isEmpty) {
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

    parsed.sort((a, b) => (a['_idx'] as int).compareTo(b['_idx'] as int));

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: parsed.length,
      itemBuilder: (context, index) {
        final entry = parsed[index];
        final payload = entry['payload'] as Map<String, dynamic>;

        // Lấy text an toàn: chấp nhận nhiều key (text, Text, TextMessage, message)
        String extractText(Map<String, dynamic> p) {
          final keys = p.keys.map((e) => e.toString()).toList();
          // ưu tiên 'text' (case-insensitive), 'message', 'Text'
          for (final k in [
            'text',
            'Text',
            'message',
            'Message',
            'TextMessage',
          ]) {
            if (p.containsKey(k)) {
              final val = p[k];
              return val == null ? '' : val.toString();
            }
          }
          // fallback: nếu map có 1 trường string, trả cái đó
          for (final k in keys) {
            final val = p[k];
            if (val is String) return val;
          }
          return '';
        }

        final text = extractText(payload);

        // --- Sửa: lấy senderUid thay vì chỉ isMe ---
        String extractSenderUid(Map<String, dynamic> p) {
          // ưu tiên trường 'sender'
          if (p.containsKey('sender') && p['sender'] != null) {
            return p['sender'].toString();
          }
          // thử một số key khác nếu cần
          if (p.containsKey('from') && p['from'] != null) {
            return p['from'].toString();
          }
          if (p.containsKey('uid') && p['uid'] != null) {
            return p['uid'].toString();
          }
          // fallback: nếu có isMe boolean, map về myUid hoặc otherUid (giả sử)
          if (p.containsKey('isMe')) {
            final v = p['isMe'];
            if (v is bool) {
              return v && myUid != null ? myUid! : (otherUid ?? '');
            }
            if (v is String) {
              // nếu lưu trực tiếp uid
              if (v == myUid || v == otherUid) return v;
              // nếu là "true"/"false"
              if (v.toLowerCase() == 'true' && myUid != null) return myUid!;
              if (v.toLowerCase() == 'false' && otherUid != null) return otherUid!;
            }
          }
          return '';
        }

        final senderUid = extractSenderUid(payload);
        final isMe = myUid != null && senderUid == myUid;
        final isOther = otherUid != null && senderUid == otherUid;

        // Truyền senderUid để buildMessageBubble xử lý hiển thị bên phải/trái
        return buildMessageBubble(text: text, senderUid: senderUid);
      },
    );
  }

  // Sửa lại param: senderUid (String) -> so sánh với myUid/otherUid bên trong
  Widget buildMessageBubble({required String text, required String senderUid}) {
    const yellowColor = Color.fromRGBO(245, 203, 88, 1);

    final bool isMe = myUid != null && senderUid == myUid;
    // Nếu sender không xác định nhưng khác myUid, coi như other (nằm bên trái)
    final bool isOther = otherUid != null && senderUid == otherUid;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar cho tin nhắn của người khác (nếu sender là other hoặc sender không xác định)
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
