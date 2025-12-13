import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';
import 'package:ucbs_attendance_app/views/login/role_selection.dart';
import 'package:ucbs_attendance_app/views/login/signin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final PageController controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: PageView(
        controller: controller,
        scrollDirection: Axis.vertical,
        children: [
          RoleSelection(controller: controller),
          Signin(),
        ],
      ),
    );
  }
}
