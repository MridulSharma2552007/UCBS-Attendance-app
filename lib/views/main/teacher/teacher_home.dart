import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';
import 'package:ucbs_attendance_app/provider/user_session.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentOrange,
      body: Center(
        child: Text(
          "Teacher Dashboard",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}
