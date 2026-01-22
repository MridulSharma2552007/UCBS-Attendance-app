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
  final GlobalKey<_ClassInfoState> _classInfoKey = GlobalKey<_ClassInfoState>();

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

  void _refreshClassInfo() {
    _classInfoKey.currentState?.fetchClassInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadTeacher(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const TeacherSkeleton();
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
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with Add Class button and profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.accentyellow,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.black, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Add Class',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: 24,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Header
                  Header(teacher: teacher),
                  const SizedBox(height: 40),

                  // Subjects
                  Text(
                    'Subjects',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SubjectCard(subjects: subjects),
                  const SizedBox(height: 40),

                  // Quick Start
                  StartClassWidget(
                    subjects: subjects,
                    onClassUpdate: _refreshClassInfo,
                  ),
                  const SizedBox(height: 40),

                  // Live Classes
                  Text(
                    'Live Classes',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClassInfo(client: client, key: _classInfoKey),
                ],
              ),
            );
          },
        ),
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

  String getGreeting() {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with emoji
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi 👋 ${widget.teacher['name']}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              getGreeting(),
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekdays.length,
            itemBuilder: (context, index) {
              final date = weekdays[index];
              final isToday = isSameDay(date, today);

              return Container(
                width: 100,
                height: 20,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.accentyellow
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: GoogleFonts.inter(
                        color: isToday ? Colors.black : Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date.day.toString(),
                      style: GoogleFonts.inter(
                        color: isToday ? Colors.black : Colors.white,
                        fontSize: 16,
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
    );
  }
}

class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subjects});
  final List<Map<String, dynamic>> subjects;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: subjects.map((subject) {
        final index = subjects.indexOf(subject);
        final colors = [
          Color(0xFFD4E87B),
          Color(0xFFFFD25F),
          Color(0xFFFF7562),
          Color(0xFF87CEEB),
          Color(0xFFDDA0DD),
        ];
        final bgColor = colors[index % colors.length];

        return Container(
          height: 180,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject title
              Text(
                subject['name'],
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 16,
                        color: Colors.black.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sem ${subject['sem']}',
                        style: GoogleFonts.inter(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class StartClassWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  final VoidCallback? onClassUpdate;

  const StartClassWidget({
    super.key,
    required this.subjects,
    this.onClassUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start Class',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Begin attendance tracking for your subjects',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                HapticFeedback.lightImpact();

                final result = await showModalBottomSheet<bool>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => StartClassSheet(subjects: subjects),
                );

                if (result == true && onClassUpdate != null) {
                  onClassUpdate!();
                }
              },
              child: Text(
                "Start Class",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
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
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClassInfo();
  }

  Future<void> fetchClassInfo() async {
    try {
      final response = await widget.client
          .from('live_class')
          .select()
          .eq('is_activated', true);

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
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    if (classes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.tv_off_outlined,
                size: 32,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                "No active classes",
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Start a class to see it here",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: classes.map((cls) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls['subjectName'],
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Semester ${cls['sem']} • Live",
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "LIVE",
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Subject',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...widget.subjects.map((subject) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                title: Text(
                  subject['name'],
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Semester ${subject['sem']}',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                onTap: () async {
                  Navigator.pop(context);

                  if (!mounted) return;

                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StartClass(
                        subjects: [
                          {"name": subject['name'], "sem": subject['sem']},
                        ],
                      ),
                    ),
                  );

                  if (mounted && result == true) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            );
          }).toList(),
        ],
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          skeletonBox(height: 24, width: 180),
          const SizedBox(height: 6),
          skeletonBox(height: 15, width: 120),
          const SizedBox(height: 24),
          skeletonBox(height: 70),
          const SizedBox(height: 40),
          skeletonBox(height: 20, width: 80),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: skeletonBox(height: 120, width: 200),
              ),
            ),
          ),
          const SizedBox(height: 40),
          skeletonBox(height: 120),
          const SizedBox(height: 40),
          skeletonBox(height: 20, width: 100),
          const SizedBox(height: 16),
          skeletonBox(height: 100),
        ],
      ),
    );
  }
}
