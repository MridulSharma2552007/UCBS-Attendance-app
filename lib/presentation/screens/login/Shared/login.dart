import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';
import 'package:ucbs_attendance_app/presentation/screens/login/Shared/role_selection.dart';
import 'package:ucbs_attendance_app/presentation/screens/login/Gates/user_info.dart';

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
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        scrollDirection: Axis.vertical,
        children: [
          RoleSelection(controller: controller),
          UserInfo(),
        ],
      ),
    );
  }
}
