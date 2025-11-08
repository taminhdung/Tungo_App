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

Uint8List _cropBytesIsolate(Uint8List inputBytes) {
  final img.Image? original = img.decodeImage(inputBytes);
  if (original == null) {
    throw Exception('Không thể decode ảnh.');
  }

  final int size = original.width < original.height
      ? original.width
      : original.height;
  final int offsetX = ((original.width - size) / 2).round();
  final int offsetY = ((original.height - size) / 2).round();

  final img.Image cropped = img.copyCrop(
    original,
    x: offsetX,
    y: offsetY,
    width: size,
    height: size,
  );

  final List<int> jpg = img.encodeJpg(cropped, quality: 90);
  return Uint8List.fromList(jpg);
}

class _MeState extends State<Me> {
  static Service service = Service();
  Map<String, dynamic>? info;

  final Map<String, String> _croppedCache = {};
  final Map<String, String> _localOverride = {};

  @override
  void initState() {
    super.initState();
    loadinformation();
  }

  Future<void> loadinformation() async {
    final data = await service.getinformation() as Map<String, dynamic>?;
    setState(() {
      info = data;
    });

    final avatarUrl = info != null && info!['avatar'] != null
        ? info!['avatar'].toString()
        : null;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      final cached = _croppedCache[avatarUrl];
      if (cached != null && File(cached).existsSync()) {
        _localOverride[avatarUrl] = cached;
        if (mounted) setState(() {});
      } else {
        _getCroppedImagePath(avatarUrl)
            .then((path) {
              if (path != null) {
                _croppedCache[avatarUrl] = path;
                _localOverride[avatarUrl] = path;
                if (mounted) setState(() {});
              }
            })
            .catchError((e) {
              debugPrint('Background crop avatar failed: $e');
            });
      }
    }
  }

  Future<String?> _getCroppedImagePath(String url) async {
    try {
      if (url.isEmpty) return null;

      final cached = _croppedCache[url];
      if (cached != null) {
        final f = File(cached);
        if (await f.exists()) return cached;
        _croppedCache.remove(url);
      }

      final uri = Uri.parse(url);
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return null;
      final bytes = resp.bodyBytes;

      final Uint8List croppedBytes = await compute<Uint8List, Uint8List>(
        _cropBytesIsolate,
        bytes,
      );

      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/avatar_cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath);
      await outFile.writeAsBytes(croppedBytes);

      _croppedCache[url] = outPath;
      return outPath;
    } catch (e) {
      debugPrint('Auto crop (avatar) error for $url: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? avatarUrl =
        (info != null &&
            info!['avatar'] != null &&
            info!['avatar'].toString().isNotEmpty)
        ? info!['avatar'].toString()
        : null;
    String? localAvatarPath = (avatarUrl != null)
        ? (_localOverride[avatarUrl] ?? _croppedCache[avatarUrl])
        : null;
    ImageProvider? backgroundImage;
    if (localAvatarPath != null && File(localAvatarPath).existsSync()) {
      backgroundImage = FileImage(File(localAvatarPath));
    } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
      backgroundImage = NetworkImage(avatarUrl);
    } else {
      backgroundImage = null;
    }

    return Drawer(
      child: Container(
        color: Color.fromRGBO(233, 83, 34, 1),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[200],
                backgroundImage: backgroundImage,
              ),
              info == null
                  ? Text(
                      "Ẩn danh",
                      style: TextStyle(color: Colors.white70, fontSize: 20),
                    )
                  : Text(
                      info!['name'],
                      style: TextStyle(color: Colors.white70, fontSize: 20),
                    ),
              info == null
                  ? Text(
                      "Ẩn danh",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    )
                  : Text(
                      info!['email'],
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
              SizedBox(height: 30),
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
                  print("Đổi mật khẩu");
                },
              ),
              MenuItem(
                icon: Icons.money_off_csred_sharp,
                title: "Đơn hàng",
                onTap: () {
                  print("Đơn hàng");
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
                onTap: () {
                  print("Cài đặt");
                },
              ),
              MenuItem(
                icon: Icons.no_accounts_outlined,
                title: "Xoá tài khoản",
                onTap: () {
                  print("Xoá tài khoản");
                },
              ),
              SizedBox(height: 181),
              MenuItem(
                icon: Icons.logout,
                title: "Đăng xuất",
                onTap: () {
                  service.signOut();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, Routers.login);
                },
                showDivider: false,
              ),
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
