import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';
import 'package:ucbs_attendance_app/provider/user_session.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.accentBlue);
  }
}
