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

                const SizedBox(height: 32),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.book_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your Subjects',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SubjectCard(subjects: subjects),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.dmSans(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StartClassWidget(
                  subjects: subjects,
                  onClassUpdate: _refreshClassInfo,
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.live_tv,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Live Classes',
                      style: GoogleFonts.dmSans(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClassInfo(client: client, key: _classInfoKey),
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
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    if (classes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 120),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.tv_off,
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Active Classes",
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start a class to see it appear here",
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: classes.map((cls) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.1),
                  Colors.red.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.live_tv, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "LIVE",
                            style: GoogleFonts.dmSans(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cls['subjectName'],
                        style: GoogleFonts.dmSans(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Semester ${cls['sem']}",
                        style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.radio_button_checked, color: Colors.red, size: 20),
              ],
            ),
          );
        }).toList(),
      ),
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
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardDark, AppColors.cardDark.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Start Class',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select a subject to begin attendance tracking',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.greenAccent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact();

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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Start",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
      height: 160,
      child: ListView.builder(
        itemCount: subjects.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final colors = [
            [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
            [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
            [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
            [Colors.teal.withOpacity(0.1), Colors.teal.withOpacity(0.05)],
          ];
          final colorPair = colors[index % colors.length];
          final iconColors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal];
          final iconColor = iconColors[index % iconColors.length];

          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colorPair,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.book,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subjects[index]['name'],
                          style: GoogleFonts.dmSans(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Semester ${subjects[index]['sem']}',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                        onTap: () async {
                          if (!mounted) return;
                          
                          final subject = widget.subjects[index];

                          print(
                            'Selected subject: ${subject['name']} | Semester: ${subject['sem']}',
                          );

                          Navigator.pop(context); // Close the bottom sheet first

                          if (!mounted) return;
                          
                          final result = await Navigator.push<bool>(
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

                          // Return the result to the parent
                          if (mounted && result == true) {
                            Navigator.pop(context, true);
                          }
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
