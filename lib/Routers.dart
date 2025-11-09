import 'package:flutter/material.dart' hide Notification;
import 'package:tungo_application/Page/File.dart';
import 'package:tungo_application/Page/Forgot_password1.dart';
import 'package:tungo_application/Page/Message.dart';
import 'package:tungo_application/Page/Orders.dart';
import 'package:tungo_application/Page/Setting.dart';
import 'package:tungo_application/Page/Shop.dart';
import 'package:tungo_application/Page/Forgot_password.dart';
import 'package:tungo_application/Page/Home.dart';
import 'package:tungo_application/Page/Login_1.dart';
import 'package:tungo_application/Page/Register.dart';
import 'package:tungo_application/Page/Supports.dart';
import 'package:tungo_application/Page/Me.dart';
import 'package:tungo_application/Page/Voucher.dart';
import 'package:tungo_application/Page/Notification.dart';
import 'package:tungo_application/Page/ShoppingCart.dart';
import 'Page/Initialization.dart';
import 'Page/Login.dart';
import 'Page/Contact.dart';
import 'Page/Showallfood.dart';

class Routers {
  static const initialization = "/initialization";
  static const default_splash = "/default_splash";
  static const login = "/login_page";
  static const login1 = "/login";
  static const register = "/register";
  static const home = "/home";
  static const contact = "/contact";
  static const showallfood = "/showallfood";
  static const voucher = "/voucher";
  static const forgot_password = "/forgot_password";
  static const forgot_password1 = "/forgot_password1";
  static const supports = "/supports";
  static const shop = "/shop";
  static const notification = "/notification";
  static const me = "/me";
  static const file = "/file";
  static const shoppingcart = "/shoppingcart";
  static const orders = "/orders";
  static const setting = "/setting";
  static const message = "/message";

  Map<String, WidgetBuilder> router_list = {
    initialization: (context) => const Initialization(),
    login: (context) => const Login(),
    login1: (context) => const Login1(),
    register: (context) => const Register(),
    home: (context) => const Home(),
    contact: (context) => const Contact(),
    showallfood: (context) => const Showallfood(),
    voucher: (context) => const Voucher(),
    forgot_password: (context) => const ForgotPassword(),
    forgot_password1: (context) => const ForgotPassword1(),
    supports: (context) => const Supports(),
    shop: (context) => const Shop(),
    notification: (context) => const Notification(),
    me: (context) => const Me(),
    file: (context) => const File(),
    shoppingcart: (context) => const Shoppingcart(),
    orders: (context) => const Orders(),
    setting: (context) => const Setting(),
    message: (context) => const Message(),
  };
}
