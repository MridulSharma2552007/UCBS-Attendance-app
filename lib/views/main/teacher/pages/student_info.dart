import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';

class StudentInfo extends StatefulWidget {
  final List<Map<String, dynamic>> studentData;
  const StudentInfo({super.key, required this.studentData});

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Text(
          'Student Info Page\nData: ${widget.studentData[0]['name']}',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
