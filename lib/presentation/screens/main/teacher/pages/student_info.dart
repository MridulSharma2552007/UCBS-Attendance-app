import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Teacher/get_student_attendance.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';

class StudentInfo extends StatefulWidget {
  final PageController _controller;
  final List<Map<String, dynamic>> studentData;
  const StudentInfo({
    super.key,
    required this.studentData,
    required PageController controller,
  }) : _controller = controller;

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  final GetStudentAttendance _attendanceService = GetStudentAttendance();
  late List<Map<String, dynamic>> subjects = [];
  late Map<int, Map<String, int>> subjectStats = {};
  late Map<int, List<Map<String, dynamic>>> subjectAttendance = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final employeeId = StorageService.getInt('employee_id') ?? 0;
    final rollNo = widget.studentData[0]['roll_no'];

    final fetchedSubjects = await _attendanceService.getTeacherSubjects(
      employeeId,
    );
    setState(() => subjects = fetchedSubjects);

    for (var subject in fetchedSubjects) {
      final stats = await _attendanceService.getAttendanceStats(
        rollNo,
        subject['id'],
      );
      final attendance = await _attendanceService.getStudentAttendanceBySubject(
        rollNo,
        subject['id'],
      );
      setState(() {
        subjectStats[subject['id']] = stats;
        subjectAttendance[subject['id']] = attendance;
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentData.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        body: const Center(
          child: Text(
            'No student data available',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final student = widget.studentData[0];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => widget._controller.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
        ),
        title: Text(
          'Student',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: Text(
                      student['name'][0].toString().toUpperCase(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'],
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Roll ${student['roll_no']} • Sem ${student['semester']}',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(
                'Attendance by Subject',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...subjects.map((subject) {
                final stats = subjectStats[subject['id']] ?? {};
                final attendance = subjectAttendance[subject['id']] ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubjectHeader(subject['name'], stats),
                    const SizedBox(height: 12),
                    _buildCalendarHeatmap(attendance),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectHeader(String subject, Map<String, int> stats) {
    final present = stats['present'] ?? 0;
    final total = stats['total'] ?? 0;
    final percentage = stats['percentage'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$present/$total classes',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          Text(
            '$percentage%',
            style: GoogleFonts.inter(
              color: const Color(0xFF00D9A3),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeatmap(List<Map<String, dynamic>> attendance) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: now.weekday - 1));
    final weeks = <List<DateTime>>[];
    final attendanceCount = <String, int>{};

    for (var record in attendance) {
      final recordDate = DateTime.parse(record['created_at']);
      final dateKey =
          '${recordDate.year}-${recordDate.month}-${recordDate.day}';
      attendanceCount[dateKey] = (attendanceCount[dateKey] ?? 0) + 1;
    }

    final maxCount = attendanceCount.values.isEmpty
        ? 1
        : attendanceCount.values.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < 12; i++) {
      final week = <DateTime>[];
      for (int j = 0; j < 7; j++) {
        final date = startDate.add(Duration(days: i * 7 + j));
        if (date.isBefore(now.add(const Duration(days: 1)))) {
          week.add(date);
        }
      }
      if (week.isNotEmpty) weeks.add(week);
    }

    Color _getHeatmapColor(int count) {
      if (count == 0) return Colors.white.withOpacity(0.05);
      final intensity = count / maxCount;
      return Color.lerp(
        const Color(0xFF00D9A3).withOpacity(0.3),
        const Color(0xFF00D9A3),
        intensity,
      )!;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          ...weeks.map((week) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children:
                    (week
                            .map((date) {
                              final dateKey =
                                  '${date.year}-${date.month}-${date.day}';
                              final count = attendanceCount[dateKey] ?? 0;

                              return Expanded(
                                child: Tooltip(
                                  message: count > 0
                                      ? '${date.day}/${date.month} - $count class(es)'
                                      : '${date.day}/${date.month} - Absent',
                                  child: Container(
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _getHeatmapColor(count),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList()
                            .expand(
                              (widget) => [widget, const SizedBox(width: 2)],
                            )
                            .toList()
                            .dropLast(1)
                        as List<Widget>),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

extension on List {
  List dropLast(int n) => sublist(0, length - n);
}
