import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ucbs_attendance_app/core/services/auth_service.dart';
import 'package:ucbs_attendance_app/data/services/Firebase/sign_in_with_google.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Teacher/verify_teacher.dart';
import 'package:ucbs_attendance_app/presentation/screens/login/Shared/sign_up.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/teacher/pages/teacher_mainpage.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/teacher/teacher_home.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

class SignInTeacher extends StatefulWidget {
  const SignInTeacher({super.key});

  @override
  State<SignInTeacher> createState() => _SignInTeacherState();
}

class _SignInTeacherState extends State<SignInTeacher> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => opacity = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/images/bg.jpeg", fit: BoxFit.cover),
            ),
            Align(
              alignment: Alignment.center,
              child: FrostedLogicCard(opacity: opacity),
            ),
          ],
        ),
      ),
    );
  }
}

class FrostedLogicCard extends StatelessWidget {
  final double opacity;

  const FrostedLogicCard({super.key, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 800),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textPrimary,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sign in with your Google account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    final user = await SignInWithGoogle().signIn();
                    if (user != null && user.email != null) {
                      final email = user.email!;
                      final name = user.displayName;
                      debugPrint('Email: $email, Name: $name');

                      final teacherData = await VerifyTeacher().getTeacherData(
                        email,
                      );
                      if (teacherData != null) {
                        debugPrint('Teacher found: $teacherData');
                        AuthService.signIn(context, teacherData);
                        print('Signed in as Teacher: $email');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeacherHome(),
                          ),
                        );
                      } else {
                        SnackBar snackBar = const SnackBar(
                          content: Text(
                            'No teacher account found for this email.',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        final googleinstance = SignInWithGoogle();
                        await googleinstance.signOut();

                        debugPrint('Teacher not found');
                      }
                    }
                  },
                  child: GoogleSignIn(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
