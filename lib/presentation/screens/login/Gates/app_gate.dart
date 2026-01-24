import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/core/constants/app_constants.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';
import 'package:ucbs_attendance_app/presentation/screens/login/Shared/login.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/home.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/teacher/teacher_home.dart';

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  Future<Widget> _decide() async {
    final isLogged = StorageService.getBool(AppConstants.isLoggedKey) ?? false;
    final role = StorageService.getString(AppConstants.roleKey);

    if (!isLogged) return const Login();

    if (role == AppConstants.studentRole) return const Home();
    if (role == AppConstants.teacherRole) return const TeacherHome();

    return const Login();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _decide(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
