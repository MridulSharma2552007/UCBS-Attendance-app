import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';

class TeacherMainpage extends StatefulWidget {
  const TeacherMainpage({super.key});

  @override
  State<TeacherMainpage> createState() => _TeacherMainpageState();
}

class _TeacherMainpageState extends State<TeacherMainpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          SizedBox(height: 80),
          Row(
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundColor: AppColors.accentBlue,
                child: Center(child: Icon(Icons.person, size: 25)),
              ),
              Text('Hello'),
            ],
          ),
        ],
      ),
    );
  }
}
