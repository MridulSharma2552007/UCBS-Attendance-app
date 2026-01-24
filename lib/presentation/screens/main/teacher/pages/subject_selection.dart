import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Teacher/get_subject_name.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/teacher/pages/teacher_mainpage.dart';

class SubjectSelection extends StatefulWidget {
  const SubjectSelection({super.key});

  @override
  State<SubjectSelection> createState() => _SubjectSelectionState();
}

class _SubjectSelectionState extends State<SubjectSelection> {
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;

  Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    try {
      subjects = await GetSubjectName().fetchSubjects();
    } catch (e) {
      debugPrint("Error loading subjects: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (subjects.isEmpty) {
      return const Center(child: Text("No Subjects Found In DB"));
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          const SizedBox(height: 50),

          Text(
            'Select Subjects',
            style: GoogleFonts.dmSans(
              color: AppColors.textPrimary,
              fontSize: 25,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Container(
              height: 700,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bgLightDark,
                borderRadius: BorderRadius.circular(20),
              ),

              child: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final bool isSelected = selectedIndexes.contains(index);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedIndexes.contains(index)) {
                          selectedIndexes.remove(index);
                        } else {
                          selectedIndexes.add(index);
                        }
                      });
                    },

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentBlue.withValues(alpha: 0.2)
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentBlue
                                : Colors.transparent,
                          ),
                        ),

                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.book, size: 40),
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject['subjectsName'],
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Semester ${subject['sem']}",
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.textFaded,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () async {
                final String? userEmail = context.read<UserSession>().email;
                if (userEmail == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Fill ALL INFORMATION WITHOUT CLOSING APP"),
                    ),
                  );
                  return;
                }

                final List<Map<String, dynamic>> selectedSubjects =
                    selectedIndexes
                        .map(
                          (i) => {
                            "name": subjects[i]['subjectsName'],
                            "sem": subjects[i]['sem'],
                          },
                        )
                        .toList();

                if (selectedSubjects.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Select at least one subject"),
                    ),
                  );
                  return;
                }

                final supabase = Supabase.instance.client;

                await supabase
                    .from('teachers')
                    .update({'subject': selectedSubjects})
                    .eq('email', userEmail);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text("Subjects saved successfully"),
                  ),
                );
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLogged', true);
                Future.delayed(Duration(seconds: 3), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherMainpage()),
                  );
                });
              },

              child: Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.accentBlue,
                ),
                child: Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
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
