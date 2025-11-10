import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../Routers.dart';
import '../Service.dart';

class Me extends StatefulWidget {
  const Me({super.key});
  @override
  State<Me> createState() => _MeState();
}

// crop avatar thành hình vuông
Uint8List _cropBytesIsolate(Uint8List inputBytes) {
  final original = img.decodeImage(inputBytes);
  if (original == null) {
    throw Exception('Không thể decode ảnh.');
  }

  final size = original.width < original.height
      ? original.width
      : original.height;
  final offsetX = ((original.width - size) / 2).round();
  final offsetY = ((original.height - size) / 2).round();

  final cropped = img.copyCrop(
    original,
    x: offsetX,
    y: offsetY,
    width: size,
    height: size,
  );

  final jpg = img.encodeJpg(cropped, quality: 90);
  return Uint8List.fromList(jpg);
}

class _MeState extends State<Me> {
  static Service service = Service();

  Map<String, dynamic>? userInfo;

  // cache cho avatar
  Map<String, String> _avatarCache = {};
  Map<String, String> _localOverride = {};

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final data = await service.getinformation() as Map<String, dynamic>?;

    setState(() {
      userInfo = data;
    });

    // load avatar nếu có
    if (userInfo != null && userInfo!['avatar'] != null) {
      String avatarUrl = userInfo!['avatar'].toString();
      if (avatarUrl.isNotEmpty) {
        _loadAvatar(avatarUrl);
      }
    }
  }

  void _loadAvatar(String url) {
    // check cache trước
    final cached = _avatarCache[url];
    if (cached != null && File(cached).existsSync()) {
      _localOverride[url] = cached;
      if (mounted) setState(() {});
      return;
    }

    // chưa có cache -> crop mới
    _getCroppedAvatar(url)
        .then((path) {
          if (path != null) {
            _avatarCache[url] = path;
            _localOverride[url] = path;
            if (mounted) setState(() {});
          }
        })
        .catchError((e) {
          debugPrint('Crop avatar failed: $e');
        });
  }

  Future<String?> _getCroppedAvatar(String url) async {
    if (url.isEmpty) return null;

    try {
      // check cache
      final cached = _avatarCache[url];
      if (cached != null) {
        final f = File(cached);
        if (await f.exists()) return cached;
        _avatarCache.remove(url);
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final croppedBytes = await compute<Uint8List, Uint8List>(
        _cropBytesIsolate,
        response.bodyBytes,
      );

      final tempDir = await getTemporaryDirectory();
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      await File(filePath).writeAsBytes(croppedBytes);

      _avatarCache[url] = filePath;
      return filePath;
    } catch (e) {
      debugPrint('Error cropping avatar: $e');
      return null;
    }
  }

  void _showSignOutDialog() {
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
                    'Bạn có chắc chắn muốn đăng xuất không?',
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
                            'Huỷ bỏ',
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
                          onPressed: () => _handleSignOut(sheetContext),
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
                            'Đăng xuất',
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

  void _showSignOutDialog1() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return GestureDetector(
          onTap: () {}, // chặn tap ra ngoài
          behavior: HitTestBehavior.opaque,
          child: WillPopScope(
            onWillPop: () async => false, // chặn nút Back
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
                    'Tính năng đang trong quá trình phát triển',
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
                            'Quay lại',
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
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(233, 83, 34, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Tôi hiểu',
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

  void _handleSignOut(BuildContext sheetContext) {
    try {
      service.signOut();
    } catch (e) {
      debugPrint('SignOut error: $e');
    }

    Navigator.of(sheetContext).pop(); // đóng bottom sheet
    Navigator.of(context).pop(); // đóng drawer
    Navigator.pushReplacementNamed(context, Routers.login);
  }

  ImageProvider? _getAvatarImage() {
    if (userInfo == null || userInfo!['avatar'] == null) {
      return null;
    }

    String avatarUrl = userInfo!['avatar'].toString();
    if (avatarUrl.isEmpty) return null;

    // ưu tiên dùng local cache
    String? localPath = _localOverride[avatarUrl] ?? _avatarCache[avatarUrl];

    if (localPath != null && File(localPath).existsSync()) {
      return FileImage(File(localPath));
    }

    return NetworkImage(avatarUrl);
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chúng tôi rất lấy làm tiếc khi bạn muốn rời Tungo, nhưng xin lưu ý các tài khoản đã bị xóa sẽ không được mở trở lại.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Hủy',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () => _handleDeleteAccount(ctx),
                    child: Text(
                      'ĐỒNG Ý',
                      style: TextStyle(
                        color: Color.fromRGBO(233, 83, 34, 1),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteAccount(BuildContext ctx) async {
    Navigator.of(ctx).pop(); // đóng dialog

    try {
      // await service.deleteAccount();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tài khoản đã được xóa (giả lập).')),
      );

      // sau khi xóa thành công -> về login
      // Navigator.pushReplacementNamed(context, Routers.login);
    } catch (e) {
      debugPrint('Delete account error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xoá tài khoản thất bại.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color.fromRGBO(233, 83, 34, 1);

    return Drawer(
      child: Container(
        color: accentColor,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),

              // avatar
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[200],
                backgroundImage: _getAvatarImage(),
              ),

              // tên
              Text(
                userInfo?['name'] ?? "Ẩn danh",
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),

              // email
              Text(
                userInfo?['email'] ?? "",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              SizedBox(height: 30),

              // menu items
              MenuItem(
                icon: Icons.person_outline,
                title: "Thông tin cá nhân",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, Routers.file);
                },
              ),

              MenuItem(
                icon: Icons.password_outlined,
                title: "Đổi mật khẩu",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(
                    context,
                    Routers.forgot_password,
                  );
                },
              ),

              MenuItem(
                icon: Icons.money_off_csred_sharp,
                title: "Đơn hàng",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, Routers.orders1);
                },
              ),

              MenuItem(
                icon: Icons.help_outline,
                title: "Liên hệ với chúng tôi",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, Routers.supports);
                },
              ),

              MenuItem(
                icon: Icons.settings_outlined,
                title: "Cài đặt",
                onTap: _showSignOutDialog1,
              ),

              MenuItem(
                icon: Icons.no_accounts_outlined,
                title: "Xoá tài khoản",
                onTap: _showDeleteAccountDialog,
              ),

              Spacer(), // đẩy logout xuống dưới cùng

              MenuItem(
                icon: Icons.logout,
                title: "Đăng xuất",
                onTap: _showSignOutDialog,
                showDivider: false,
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Color.fromRGBO(233, 83, 34, 1),
                size: 24,
              ),
            ),
            SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
