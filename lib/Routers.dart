import 'package:flutter/material.dart' hide Notification;
import 'package:tungo_application/Page/Forgot_password1.dart';
import 'package:tungo_application/Page/Forgot_password2.dart';
import 'package:tungo_application/Page/Shop.dart';
import 'package:tungo_application/Page/Forgot_password.dart';
import 'package:tungo_application/Page/Home.dart';
import 'package:tungo_application/Page/Login_1.dart';
import 'package:tungo_application/Page/Register.dart';
import 'package:tungo_application/Page/Supports.dart';
import 'package:tungo_application/Page/Me.dart';
import 'package:tungo_application/Page/Voucher.dart';
import 'package:tungo_application/Page/Notification.dart';
import 'Page/Initialization.dart';
import 'Page/Login.dart';
import 'Page/Tungo.dart';
import 'Page/Showallproduct.dart';

class Routers {
  static const initialization = "/initialization";
  static const default_splash = "/default_splash";
  static const login = "/login_page";
  static const login1 = "/login";
  static const register = "/register";
  static const home = "/home";
  static const tungo = "/tungo";
  static const showallproduct = "/showallproduct";
  static const voucher = "/voucher";
  static const forgot_password = "/forgot_password";
  static const forgot_password1 = "/forgot_password1";
  static const forgot_password2 = "/forgot_password2";
  static const supports = "/supports";
  static const shop = "/shop";
  static const notification = "/notification";
  static const me = "/me";

  Map<String, WidgetBuilder> router_list = {
    initialization: (context) => const Initialization(),
    login: (context) => const Login(),
    login1: (context) => const Login1(),
    register: (context) => const Register(),
    home: (context) => const Home(),
    tungo: (context) => const Tungo(),
    showallproduct: (context) => const Showallproduct(),
    voucher: (context) => const Voucher(),
    forgot_password: (context) => const ForgotPassword(),
    forgot_password1: (context) => const ForgotPassword1(),
    forgot_password2: (context) => const ForgotPassword2(),
    supports: (context) => const Supports(),
    shop: (context) => const Shop(),
    notification: (context) => const Notification(),
    me: (context) => const Me(),
  };
}
