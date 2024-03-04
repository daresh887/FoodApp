import 'package:flutter/material.dart';
import 'package:products_app/pages/login_page.dart';
import 'package:products_app/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void TogglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: TogglePages);
    } else {
      print("this");

      return RegisterPage(onTap: TogglePages);
    }
  }
}
