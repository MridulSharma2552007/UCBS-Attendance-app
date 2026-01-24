// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';

class RoleSelection extends StatefulWidget {
  final PageController controller;
  const RoleSelection({super.key, required this.controller});

  @override
  State<RoleSelection> createState() => _RoleSelectionState();
}

class _RoleSelectionState extends State<RoleSelection> {
  double opacity = 0.0;
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        opacity = 1.0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: SvgPicture.asset(
              'assets/images/Shape 1.svg',
              width: 120,
              height: 120,
              color: Colors.deepOrange.withOpacity(0.7),
            ),
          ),
          Positioned(
            top: 650,
            right: -20,
            child: SvgPicture.asset(
              'assets/images/Shape 5.svg',
              width: 120,
              height: 120,
              color: Colors.deepOrange.withOpacity(0.7),
            ),
          ),
          Positioned(
            top: 80,
            left: -15,
            child: SvgPicture.asset(
              'assets/images/Shape 15.svg',
              width: 130,
              height: 130,
              color: Colors.deepOrange.withOpacity(0.7),
            ),
          ),
          Positioned(
            top: 450,
            left: -20,
            child: SvgPicture.asset(
              'assets/images/Shape 2.svg',
              width: 130,
              height: 130,
              color: Colors.deepOrange.withOpacity(0.7),
            ),
          ),

          Positioned(
            top: 140,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              opacity: opacity,

              duration: Duration(milliseconds: 1000),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 600,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text(
                          'Welcome To FaceMark',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Ai attendance system for UCBS',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 50),
                        Text(
                          'Select your Role',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 50),
                        ChoiceContainer(
                          roll: 'Teacher',
                          description: 'Manage attendance \nreports',
                          color: AppColors.error,
                          ontap: () {
                            context.read<UserSession>().setrole("Teacher");
                            widget.controller.animateToPage(
                              1,
                              duration: Duration(milliseconds: 350),
                              curve: Curves.easeIn,
                            );
                          },
                          icon: Icons.account_box,
                        ),
                        SizedBox(height: 20),
                        ChoiceContainer(
                          roll: 'Student',
                          description: 'Mark attendance \nview progress',
                          color: AppColors.accentPurple,
                          ontap: () {
                            context.read<UserSession>().setrole("Student");
                            widget.controller.animateToPage(
                              1,
                              duration: Duration(milliseconds: 350),
                              curve: Curves.easeIn,
                            );
                          },
                          icon: Icons.keyboard_command_key_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChoiceContainer extends StatefulWidget {
  final String roll;
  final String description;
  final Color color;
  final VoidCallback ontap;
  final IconData icon;

  const ChoiceContainer({
    super.key,
    required this.roll,
    required this.description,
    required this.color,
    required this.ontap,
    required this.icon,
  });

  @override
  State<ChoiceContainer> createState() => _ChoiceContainerState();
}

class _ChoiceContainerState extends State<ChoiceContainer> {
  double _scale = 1.0;
  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });

    widget.ontap();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: widget.ontap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,

        child: AnimatedScale(
          scale: _scale,
          duration: Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.color),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),

            child: Row(
              children: [
                SizedBox(width: 20),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: widget.color.withValues(alpha: 0.4),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(child: Icon(widget.icon, size: 50)),
                ),
                SizedBox(width: 25),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      widget.roll,
                      style: GoogleFonts.dmSans(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      widget.description,
                      style: GoogleFonts.dmSans(
                        color: AppColors.textFaded,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
