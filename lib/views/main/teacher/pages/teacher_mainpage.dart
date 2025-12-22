import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';

class TeacherMainpage extends StatefulWidget {
  const TeacherMainpage({super.key});

  @override
  State<TeacherMainpage> createState() => _TeacherMainpageState();
}

class _TeacherMainpageState extends State<TeacherMainpage> {
  // 🔹 Get employee ID as INT
  Future<int?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('employee_id');
  }

  // 🔹 Fetch teacher data using INT
  Future<Map<String, dynamic>> getTeacherData(int employeeId) async {
    final client = Supabase.instance.client;

    final response = await client
        .from('teachers')
        .select()
        .eq('employee_id', employeeId)
        .single();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: FutureBuilder<int?>(
        future: getEmployeeId(),
        builder: (context, idSnapshot) {
          if (idSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final int? employeeId = idSnapshot.data;

          // ❌ No ID stored
          if (employeeId == null) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _header(name: '—', employeeId: 'Not found'),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Employee ID not found",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ✅ ID exists → fetch teacher data
          return FutureBuilder<Map<String, dynamic>>(
            future: getTeacherData(employeeId),
            builder: (context, teacherSnapshot) {
              if (teacherSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (teacherSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${teacherSnapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final teacher = teacherSnapshot.data!;
              final String name = teacher['name'] ?? 'Unknown';
              final List subjects = teacher['subjects'] ?? [];

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(
                        name: name,
                        employeeId: employeeId.toString(),
                      ),
                      const SizedBox(height: 24),
                      _subjectsCard(subjects),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🧑‍🏫 Header UI
  Widget _header({
    required String name,
    required String employeeId,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.accentBlue,
          child: const Icon(Icons.person, size: 32, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Employee ID: $employeeId",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  // 📚 Subjects UI
  Widget _subjectsCard(List subjects) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Subjects",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          subjects.isEmpty
              ? const Text(
                  "No subjects assigned",
                  style: TextStyle(color: Colors.grey),
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: subjects.map<Widget>((subject) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentBlue,
                        ),
                      ),
                      child: Text(
                        subject.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
