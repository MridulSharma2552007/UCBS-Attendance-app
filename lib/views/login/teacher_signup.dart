// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';
import 'package:ucbs_attendance_app/provider/user_session.dart';
import 'package:ucbs_attendance_app/views/login/sign_in_teacher.dart';
import 'package:ucbs_attendance_app/views/login/sign_up.dart';

class TeacherLogin extends StatefulWidget {
  const TeacherLogin({super.key});

  @override
  State<TeacherLogin> createState() => _TeacherLoginState();
}

class _TeacherLoginState extends State<TeacherLogin> {
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

            /// Center Card
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

class FrostedLogicCard extends StatefulWidget {
  final double opacity;

  const FrostedLogicCard({super.key, required this.opacity});

  @override
  State<FrostedLogicCard> createState() => _FrostedLogicCardState();
}

class _FrostedLogicCardState extends State<FrostedLogicCard> {
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController employeeidcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return AnimatedOpacity(
      opacity: widget.opacity,
      duration: const Duration(milliseconds: 800),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: keyboardOpen
              ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
              : ImageFilter.blur(sigmaX: 8, sigmaY: 8),

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

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Enter Your Details',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'Data will be pushed to Supabase\nwhen AI detects you as a human',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Name
                  CustomTextFields(
                    textfieldhint: 'Enter Your Name',
                    inputType: TextInputType.text,
                    controller: namecontroller,
                  ),

                  /// Employee Id
                  CustomTextFields(
                    textfieldhint: 'Enter Your Employee Id',
                    inputType: TextInputType.number,
                    controller: employeeidcontroller,
                  ),

                  Container(
                    height: 55,
                    margin: const EdgeInsets.only(top: 12, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          final name = namecontroller.text.trim();
                          final empId = employeeidcontroller.text.trim();

                          if (name.isEmpty || empId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all details"),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                     

                         
                          final prefs = await SharedPreferences.getInstance();

                          final int employeeId = int.parse(empId);
                          await prefs.setInt('employee_id', employeeId);
                               context.read<UserSession>().setName(name);
                          context.read<UserSession>().setEmployeeId(employeeId);                          

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUp()),
                          );
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Submit'),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Already logged in?",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInTeacher(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextFields extends StatelessWidget {
  final String textfieldhint;
  final TextInputType inputType;
  final TextEditingController controller;
  const CustomTextFields({
    super.key,
    required this.textfieldhint,
    required this.inputType,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            style: const TextStyle(color: Colors.white),

            inputFormatters: [
              if (inputType == TextInputType.number)
                FilteringTextInputFormatter.digitsOnly,

              LengthLimitingTextInputFormatter(30),
            ],

            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: textfieldhint,
              hintStyle: TextStyle(color: AppColors.textFaded),
            ),
          ),
        ),
      ),
    );
  }
}
