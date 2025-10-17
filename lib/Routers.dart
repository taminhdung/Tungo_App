import 'package:flutter/material.dart';
import 'package:tungo_application/Page/Forgot_password.dart';
import 'package:tungo_application/Page/Home.dart';
import 'package:tungo_application/Page/Login_1.dart';
import 'package:tungo_application/Page/Register.dart';
import 'package:tungo_application/Page/Supports.dart';
import 'package:tungo_application/Page/Voucher.dart';
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
  static const supports = "/supports";

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
    supports: (context) => const Supports(),
  };
}
