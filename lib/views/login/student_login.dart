import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  State<StudentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  double opacity = 0.0;
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _rollnocontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => opacity = 1.0);
    });
  }

  @override
  void dispose() {
    _namecontroller.dispose();
    _rollnocontroller.dispose();
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
              child: Image.asset('assets/images/bg.jpeg', fit: BoxFit.cover),
            ),

            Align(
              alignment: Alignment.center,
              child: FrostedStudentCard(
                opacity: opacity,
                nameController: _namecontroller,
                rollNoController: _rollnocontroller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FrostedStudentCard extends StatelessWidget {
  final double opacity;
  final TextEditingController nameController;
  final TextEditingController rollNoController;

  const FrostedStudentCard({
    super.key,
    required this.opacity,
    required this.nameController,
    required this.rollNoController,
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
                    'Enter Your Details',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Data will be verified before attendance marking',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 40),

                  CustomTextFields(
                    textfieldhint: 'Enter Your Name',
                    inputType: TextInputType.text,
                    controller: nameController,
                  ),

                  CustomTextFields(
                    textfieldhint: 'Enter Roll Number',
                    inputType: TextInputType.number,
                    controller: rollNoController,
                  ),

                  StudentDropdown(
                    label: "Choose your Sem",
                    options: ["1", "2", "3", "4", "5", "6"],
                  ),

                  const SizedBox(height: 30),
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
  final TextEditingController controller;
  final String textfieldhint;
  final TextInputType inputType;

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

class StudentDropdown extends StatefulWidget {
  final String label;
  final List<String> options;
  // final Function(String) onChanged;

  const StudentDropdown({
    super.key,
    required this.label,
    required this.options,
    // required this.onChanged,
  });

  @override
  State<StudentDropdown> createState() => _StudentDropdownState();
}

class _StudentDropdownState extends State<StudentDropdown> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.black.withOpacity(0.9),
          style: TextStyle(color: Colors.white),
          hint: Text(widget.label, style: TextStyle(color: Colors.white54)),
          value: selectedOption,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          items: widget.options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: (value) {
            setState(() => selectedOption = value);
            // widget.onChanged(value!);
          },
        ),
      ),
    );
  }
}
