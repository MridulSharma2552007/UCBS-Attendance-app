import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/core/services/auth_service.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: ElevatedButton(
          onPressed: () => AuthService.signOut(context),
          child: Text('Logout'),
        ),
      ),
    );
  }
}
