import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';
import 'package:ucbs_attendance_app/views/main/teacher/pages/start_class.dart';

class TeacherMainpage extends StatefulWidget {
  const TeacherMainpage({super.key});

  @override
  State<TeacherMainpage> createState() => _TeacherMainpageState();
}

class _TeacherMainpageState extends State<TeacherMainpage> {
  final client = Supabase.instance.client;
  Future<Map<String, dynamic>> _loadTeacher() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getInt('employee_id');
    if (employeeId == null) {
      throw Exception("Employee ID not found In DB");
    }

    final data = await client
        .from('teachers')
        .select()
        .eq('employee_id', employeeId)
        .single();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadTeacher(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: TeacherSkeleton());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final teacher = snapshot.data!;
          final List<Map<String, dynamic>> subjects =
              List<Map<String, dynamic>>.from(teacher['subject'] ?? []);
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Header(teacher: teacher),
                Text(
                  'Your Subjects',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 10),
                SubjectCard(subjects: subjects),
                SizedBox(height: 10),
                Text(
                  'Start a Class',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textSecondary,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                StartClassWidget(subjects: subjects),
                SizedBox(height: 30),
                Text(
                  'Classes Info',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textSecondary,
                    fontSize: 20,
                  ),
                ),
                ClassInfo(client: client),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ClassInfo extends StatefulWidget {
  final SupabaseClient client;
  const ClassInfo({super.key, required this.client});

  @override
  State<ClassInfo> createState() => _ClassInfoState();
}

class _ClassInfoState extends State<ClassInfo> {
  @override
  void initState() {
    super.initState();
    fetchClassInfo();
  }

  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;
  Future<void> fetchClassInfo() async {
    try {
      final response = await widget.client
          .from('live_class')
          .select()
          .eq('is_activated', true);
      print("LIVE CLASS RESPONSE: $response");

      if (!mounted) return;

      setState(() {
        classes = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Class fetch error: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(120),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accentBlue),
        ),
      );
    }

    if (classes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: Text(
          "No active classes at the moment.",
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: classes.map((cls) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "🟢 ${cls['subjectName']}",
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                "Semester: ${cls['sem']}",
                style: GoogleFonts.dmSans(color: Colors.white60),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class StartClassWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  const StartClassWidget({super.key, required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.cardDark,

        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Quick Actions',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Start Class',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Select a subject and all students will be notifies',
              style: GoogleFonts.dmSans(
                fontSize: 18,

                color: AppColors.textPrimary,
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.bgDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => StartClassSheet(subjects: subjects),
                      );
                    },

                    child: const Text("Start"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subjects});

  final List<Map<String, dynamic>> subjects;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: subjects.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              height: 200,
              width: 300,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 6),
                    Text("📑", style: TextStyle(fontSize: 16)),
                    Text(
                      subjects[index]['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      'Semester: ${subjects[index]['sem']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Header extends StatefulWidget {
  const Header({super.key, required this.teacher});

  final Map<String, dynamic> teacher;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late DateTime today;
  late List<DateTime> weekdays;

  String getDate() {
    final time = DateTime.now().hour;
    if (time < 12) return "Good morning";
    if (time < 17) return "Good afternoon";
    return "Good evening";
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    weekdays = List.generate(7, (i) => today.add(Duration(days: i - 2)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hi, ${widget.teacher['name']}',
                style: GoogleFonts.dmSans(
                  fontSize: 36,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            getDate(),
            style: GoogleFonts.dmSans(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekdays.length,
              itemBuilder: (context, index) {
                final date = weekdays[index];
                final isToday = isSameDay(date, today);

                return Container(
                  width: 64,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.accentBlue.withOpacity(0.8)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StartClassSheet extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  const StartClassSheet({super.key, required this.subjects});

  @override
  State<StartClassSheet> createState() => _StartClassSheetState();
}

class _StartClassSheetState extends State<StartClassSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.60,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Text(
                  'Select Subject',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.subjects.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          widget.subjects[index]['name'],
                          style: GoogleFonts.dmSans(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Semester: ${widget.subjects[index]['sem']}',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        onTap: () {
                          final subject = widget.subjects[index];

                          print(
                            'Selected subject: ${subject['name']} | Semester: ${subject['sem']}',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StartClass(
                                subjects: [
                                  {
                                    "name": subject['name'],
                                    "sem": subject['sem'],
                                  },
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeacherSkeleton extends StatelessWidget {
  const TeacherSkeleton({super.key});

  Widget skeletonBox({
    double height = 20,
    double width = double.infinity,
    double radius = 12,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          // Header
          skeletonBox(height: 36, width: 200),
          const SizedBox(height: 8),
          skeletonBox(height: 18, width: 140),

          const SizedBox(height: 30),

          skeletonBox(height: 20, width: 120),
          const SizedBox(height: 10),

          // Subject cards
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: skeletonBox(height: 200, width: 300, radius: 18),
              ),
            ),
          ),

          const SizedBox(height: 20),
          skeletonBox(height: 20, width: 120),
          const SizedBox(height: 10),

          // Start class card
          skeletonBox(height: 200, radius: 20),

          const SizedBox(height: 30),
          skeletonBox(height: 20, width: 120),
          const SizedBox(height: 10),

          skeletonBox(height: 200, radius: 20),
        ],
      ),
    );
  }
}
