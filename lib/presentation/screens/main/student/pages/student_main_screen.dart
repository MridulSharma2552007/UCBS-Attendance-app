import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

class StudentMainScreen extends StatelessWidget {
  const StudentMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudentTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            SizedBox(height: 10),
            _buildHeader(),
            SizedBox(height: 40),
            _buildWeeklyChart(),
          ],
        ),
      ),
    );
  }
}

Widget _buildHeader() {
  final String studentname = StorageService.getString('UserName')!;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hello, $studentname!👋',
            style: GoogleFonts.dmSans(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          Container(
            margin: const EdgeInsets.only(left: 10),
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StudentTheme.cardcolor,
              image: FirebaseAuth.instance.currentUser?.photoURL != null
                  ? DecorationImage(
                      image: NetworkImage(
                        FirebaseAuth.instance.currentUser!.photoURL!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
        ],
      ),
      Text(
        'Your attendance for today',
        style: GoogleFonts.dmSans(fontSize: 20, color: AppColors.textFaded),
      ),
    ],
  );
}

Widget _buildWeeklyChart() {
  DateTime now = DateTime.now();
  int currentDay = now.weekday;
  return Container(height: 70, padding: const EdgeInsets.all(20));
}
