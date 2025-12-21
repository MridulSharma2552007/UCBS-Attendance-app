import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void setlogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLogged", true);
  }

  @override
  void initState() {
    setlogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.accentBlue);
  }
}
