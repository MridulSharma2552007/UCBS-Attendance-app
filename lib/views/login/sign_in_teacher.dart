import 'dart:ui';

import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:ucbs_attendance_app/colors/colors.dart';
import 'package:ucbs_attendance_app/provider/user_session.dart';
import 'package:ucbs_attendance_app/views/login/scan_screen.dart';

class SignInTeacher extends StatefulWidget {
  const SignInTeacher({super.key});

  @override
  State<SignInTeacher> createState() => _SignInTeacherState();
}

class _SignInTeacherState extends State<SignInTeacher> {
  double opacity = 0.0;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => opacity = 1.0);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    employeeIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/bg.jpeg",
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: FrostedLogicCard(
                opacity: opacity,
                nameController: nameController,
                employeeIdController: employeeIdController,
                passwordController: passwordController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FrostedLogicCard extends StatelessWidget {
  final double opacity;
  final TextEditingController nameController;
  final TextEditingController employeeIdController;
  final TextEditingController passwordController;

  const FrostedLogicCard({
    super.key,
    required this.opacity,
    required this.nameController,
    required this.employeeIdController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return AnimatedOpacity(
      opacity: opacity,
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
                    'Welcome Back',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 25,
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
                  const SizedBox(height: 20),

                  CustomTextFields(
                    controller: nameController,
                    textfieldhint: 'Enter Your Name',
                    inputType: TextInputType.text,
                  ),

                  CustomTextFields(
                    controller: employeeIdController,
                    textfieldhint: 'Enter Your Employee ID',
                    inputType: TextInputType.number,
                  ),

                  CustomTextFields(
                    controller: passwordController,
                    textfieldhint: 'Enter Your Password',
                    inputType: TextInputType.text,
                    obscureText: true,
                  ),

                  const SizedBox(height: 25),

                  ActionSlider.standard(
                    height: 60,
                    sliderBehavior: SliderBehavior.stretch,
                    toggleColor: Colors.deepOrange.withOpacity(0.7),
                    backgroundColor: Colors.white.withOpacity(0.12),
                    foregroundBorderRadius: BorderRadius.circular(18),
                    backgroundBorderRadius: BorderRadius.circular(18),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    child: Text(
                      "Slide to begin",
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    action: (controller) async {
                      controller.loading();

                      await Future.delayed(const Duration(milliseconds: 600));

                      if (nameController.text.trim().isEmpty ||
                          employeeIdController.text.trim().isEmpty ||
                          passwordController.text.trim().isEmpty) {
                        controller.reset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all details"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      controller.success();

                      context.read<UserSession>().setName(
                            nameController.text,
                          );
                      context.read<UserSession>().setrollno(
                            employeeIdController.text,
                          );

                      await Future.delayed(const Duration(milliseconds: 400));

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanScreen(),
                        ),
                      );
                    },
                  ),
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
  final bool obscureText;

  const CustomTextFields({
    super.key,
    required this.textfieldhint,
    required this.inputType,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextField(
          controller: controller,
          keyboardType: inputType,
          obscureText: obscureText,
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
    );
  }
}
