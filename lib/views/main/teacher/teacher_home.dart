import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/views/main/teacher/navbar/navbar.dart';
import 'package:ucbs_attendance_app/views/main/teacher/pages/report.dart';
import 'package:ucbs_attendance_app/views/main/teacher/pages/search.dart';
import 'package:ucbs_attendance_app/views/main/teacher/pages/settings.dart';
import 'package:ucbs_attendance_app/views/main/teacher/pages/teacher_mainpage.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    TeacherMainpage(),
    Search(),
    Report(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Navbar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
