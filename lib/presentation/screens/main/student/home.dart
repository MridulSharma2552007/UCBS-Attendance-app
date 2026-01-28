import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/Navigation/snav_bar.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,

      body: Stack(
        children: [
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: SnavBar(onTap: (int p1) {}, currentIndex: 0),
          ),
        ],
      ),
    );
  }
}
