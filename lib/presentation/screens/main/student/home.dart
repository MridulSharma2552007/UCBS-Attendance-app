import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/Navigation/snav_bar.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/pages/study_material.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/pages/profile_screen_student.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/pages/search_student.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/pages/student_main_screen.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    StudentMainScreen(),
    SearchStudent(),
    StudyMaterial(),
    ProfileScreenStudent(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,

      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: SnavBar(
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              currentIndex: _currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}
