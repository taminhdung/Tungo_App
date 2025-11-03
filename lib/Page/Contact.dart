import 'package:flutter/material.dart';
import '../Routers.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});
  State<Contact> createState() => _Contactstate();
}

class _Contactstate extends State<Contact> {
  Future<void> openEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'taminhdung.it@gmail.com',
    );
    await launchUrl(
      emailLaunchUri,
      mode: LaunchMode.externalApplication,
      webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
    );
  }

  Future<void> openTelegram() async {
    const username = "taminhdung2001"; // thay bằng username Telegram của bạn

    // Link mở app Telegram (tg://)
    final Uri telegramApp = Uri.parse("tg://resolve?domain=$username");

    // Link fallback mở trình duyệt
    final Uri telegramWeb = Uri.parse("https://t.me/$username");

    if (await canLaunchUrl(telegramApp)) {
      await launchUrl(
        telegramApp,
        mode: LaunchMode.externalApplication, // mở ngoài app
      );
    } else {
      await launchUrl(telegramWeb, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openZalo() async {
    const phone = "0389957512";
    final Uri zaloApp = Uri.parse("zalo://chat?phone=$phone");
    final Uri zaloWeb = Uri.parse("https://zalo.me/$phone");

    if (await canLaunchUrl(zaloApp)) {
      await launchUrl(zaloApp, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(zaloWeb, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openFacebook() async {
    const fbUsername = "ta.minh.dung.758901"; // 👈 thay bằng username của bạn
    final Uri fbApp = Uri.parse(
      "fb://facewebmodal/f?href=https://www.facebook.com/$fbUsername",
    );
    final Uri fbWeb = Uri.parse("https://www.facebook.com/$fbUsername");

    if (await canLaunchUrl(fbApp)) {
      await launchUrl(fbApp, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(fbWeb, mode: LaunchMode.externalApplication);
    }
  }

  void openselectcontact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Liên hệ",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Color.fromRGBO(243, 233, 181, 1),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(252, 142, 106, 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: IconButton(
                    onPressed: openEmail,
                    icon: Row(
                      children: [
                        Image.asset("assets/images/gmail.png", width: 40),
                        SizedBox(width: 15),
                        Text("Gmail", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(252, 142, 106, 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: IconButton(
                    onPressed: openTelegram,
                    icon: Row(
                      children: [
                        Image.asset("assets/images/telegram.png", width: 40),
                        SizedBox(width: 15),
                        Text("Telegram", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(252, 142, 106, 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: IconButton(
                    onPressed: openZalo,
                    icon: Row(
                      children: [
                        Image.asset("assets/images/zalo.png", width: 40),
                        SizedBox(width: 15),
                        Text("Zalo", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(252, 142, 106, 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: IconButton(
                    onPressed: openFacebook,
                    icon: Row(
                      children: [
                        Image.asset("assets/images/facebook.png", width: 40),
                        SizedBox(width: 15),
                        Text("Facebook", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(252, 142, 106, 1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(252, 142, 106, 1),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Chăm sóc khách hàng\n24/7",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),textAlign: TextAlign.center ,
            ),
            const SizedBox(height: 30),
            const Image(
              image: AssetImage("assets/images/robot_logo.png"),
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 30),
            Container(
              width: 180,
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(245, 203, 88, 1),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: TextButton(
                onPressed: () => openselectcontact(),
                child: Text(
                  "Liên hệ",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 180,
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(243, 233, 181, 1),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Routers.home);
                },
                child: Text(
                  "Thoát",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
