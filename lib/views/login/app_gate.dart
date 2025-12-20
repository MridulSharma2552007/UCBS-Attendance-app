import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucbs_attendance_app/views/login/login.dart';
import 'package:ucbs_attendance_app/views/main/student/home.dart';
import 'package:ucbs_attendance_app/views/main/teacher/teacher_home.dart';

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  Future<Widget> _decide() async {
    final prefs = await SharedPreferences.getInstance();

    final isLogged = prefs.getBool('isLogged') ?? false;
    final role = prefs.getString('role');

    if (!isLogged) return const Login();

    if (role == "Student") return const Home();
    if (role == "Teacher") return const TeacherHome();

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
