import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';
import 'package:ucbs_attendance_app/provider/user_session.dart';
import 'package:ucbs_attendance_app/views/login/student_login.dart';
import 'package:ucbs_attendance_app/views/login/teacher_signup.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSession>();
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: session.role == "Teacher" ? const TeacherLogin() : StudentLogin(),
    );
  }
}
