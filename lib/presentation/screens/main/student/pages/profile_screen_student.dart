import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ucbs_attendance_app/core/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Student/get_attendance.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

class ProfileScreenStudent extends StatefulWidget {
  const ProfileScreenStudent({super.key});

  @override
  State<ProfileScreenStudent> createState() => _ProfileScreenStudentState();
}

class _ProfileScreenStudentState extends State<ProfileScreenStudent> {
  static List<Map<String, dynamic>>? _cachedData;
  final GetAttendance _getAttendance = GetAttendance();
  final roll_no = StorageService.getString('roll_no');

  @override
  void initState() {
    super.initState();
    if (_cachedData == null) {
      _getAttendance.getAttendanceStream(roll_no!).first.then((data) {
        _cachedData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudentTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            Padding(
              padding: EdgeInsets.all(20),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getAttendance.getAttendanceStream(roll_no!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    _cachedData = data;
                    return _buildAttendanceStats(data);
                  }
                  if (_cachedData != null) {
                    return _buildAttendanceStats(_cachedData!);
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStats(List<Map<String, dynamic>> data) {
    final totalClasses = data.length;
    final subjectMap = <String, int>{};
    final dailyMap = <DateTime, int>{};
    final dailySubjectsMap = <String, List<String>>{};

    for (var record in data) {
      final subject = record['subject'] as String? ?? 'Unknown';
      subjectMap[subject] = (subjectMap[subject] ?? 0) + 1;

      final date = DateTime.parse(record['created_at'] as String);
      final dateOnly = DateTime(date.year, date.month, date.day);
      dailyMap[dateOnly] = (dailyMap[dateOnly] ?? 0) + 1;

      final dateKey = '${dateOnly.day}/${dateOnly.month}';
      dailySubjectsMap.putIfAbsent(dateKey, () => []);
      if (!dailySubjectsMap[dateKey]!.contains(subject)) {
        dailySubjectsMap[dateKey]!.add(subject);
      }
    }

    final sortedDates = dailyMap.keys.toList()..sort();
    final last7Days = sortedDates.length > 7
        ? sortedDates.sublist(sortedDates.length - 7)
        : sortedDates;

    final last7DaysMap = <String, int>{};
    for (var date in last7Days) {
      last7DaysMap['${date.day}/${date.month}'] = dailyMap[date]!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                'Total Classes',
                totalClasses.toString(),
                StudentTheme.accentcoral,
                Icons.check_circle,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatsCard(
                'This Week',
                _getWeeklyCount(dailyMap).toString(),
                StudentTheme.primarypink,
                Icons.calendar_today,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildSubjectChart(subjectMap),
        SizedBox(height: 20),
        _buildDateChart(last7DaysMap, dailySubjectsMap),
        SizedBox(height: 20),
        _buildSubjectBreakdown(subjectMap),
        SizedBox(height: 80),
      ],
    );
  }

  int _getWeeklyCount(Map<DateTime, int> dailyMap) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    for (var date in dailyMap.keys) {
      if (date.isAfter(weekStart) &&
          date.isBefore(now.add(Duration(days: 1)))) {
        count += dailyMap[date]!;
      }
    }
    return count;
  }

  Widget _buildStatsCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectChart(Map<String, int> subjectMap) {
    final subjects = subjectMap.keys.toList();
    final counts = subjectMap.values.toList();
    final chartWidth = (subjects.length * 80).toDouble();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance by Subject',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth > 300 ? chartWidth : 300,
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      (counts.isNotEmpty
                              ? counts.reduce((a, b) => a > b ? a : b)
                              : 5)
                          .toDouble() +
                      1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= subjects.length)
                            return SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              subjects[value.toInt()].length > 10
                                  ? '${subjects[value.toInt()].substring(0, 10)}...'
                                  : subjects[value.toInt()],
                              style: GoogleFonts.inter(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    subjects.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: counts[index].toDouble(),
                          color: StudentTheme.accentcoral,
                          width: 40,
                          borderRadius: BorderRadius.circular(8),
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

  Widget _buildDateChart(
    Map<String, int> dateMap,
    Map<String, List<String>> dailySubjectsMap,
  ) {
    final sortedEntries = dateMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final dates = sortedEntries.map((e) => e.key).toList();
    final counts = sortedEntries.map((e) => e.value).toList();
    final formattedDates = dates.map((d) => _formatDate(d)).toList();
    final chartWidth = (dates.length * 80).toDouble();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Attendance',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth > 300 ? chartWidth : 300,
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      (counts.isNotEmpty
                              ? counts.reduce((a, b) => a > b ? a : b)
                              : 5)
                          .toDouble() +
                      1,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dateKey = dates[groupIndex];
                        final subjects = dailySubjectsMap[dateKey] ?? [];
                        final subjectText = subjects.join(', ');
                        return BarTooltipItem(
                          '${formattedDates[groupIndex]}\n${rod.toY.toInt()} classes\n$subjectText',
                          GoogleFonts.inter(color: Colors.white, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= formattedDates.length)
                            return SizedBox.shrink();
                          return Text(
                            formattedDates[index],
                            style: GoogleFonts.inter(fontSize: 9),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    dates.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: counts[index].toDouble(),
                          color: StudentTheme.accentcoral,
                          width: 40,
                          borderRadius: BorderRadius.circular(8),
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

  String _formatDate(String dateStr) {
    final parts = dateStr.split('/');
    final day = parts[0];
    final month = int.parse(parts[1]);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '$day ${months[month - 1]}';
  }

  Widget _buildSubjectBreakdown(Map<String, int> subjectMap) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Breakdown',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...subjectMap.entries.map((entry) {
            final percentage =
                (entry.value / subjectMap.values.reduce((a, b) => a + b)) * 100;
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: StudentTheme.accentcoral,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(
                        StudentTheme.accentcoral,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

Widget _buildProfileHeader(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  final photoUrl = user?.photoURL;
  final name = user?.displayName ?? 'Student';
  final email = user?.email ?? '';

  return Consumer<UserSession>(
    builder: (context, userSession, _) {
      final sem = StorageService.getInt('semester');

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [StudentTheme.accentcoral, StudentTheme.primarypink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            children: [
              IconButton(
                onPressed: () => AuthService.signOut(context),
                icon: Icon(Icons.logout_rounded),
                color: Colors.white,
                iconSize: 30,
              ),
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                  image: photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.white.withOpacity(0.3),
                ),
                child: photoUrl == null
                    ? Icon(Icons.person, size: 70, color: Colors.white)
                    : null,
              ),
              SizedBox(height: 20),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showSemesterChangeDialog(context, email),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Semester: $sem',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.edit, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showSemesterChangeDialog(BuildContext context, String userEmail) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Change Semester'),
      content: Text(
        'Email hpu.ucbs@gmail.com with your email ($userEmail) to change your semester. You will receive a confirmation message when your semester is updated.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            _sendEmail(userEmail);
            Navigator.pop(context);
          },
          child: Text('Send Email'),
        ),
      ],
    ),
  );
}

Future<void> _sendEmail(String userEmail) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'hpu.ucbs@gmail.com',
    queryParameters: {
      'subject': 'Semester Change Request',
      'body': 'Please change my semester. My email: $userEmail',
    },
  );

  try {
    await launchUrl(emailUri);
  } catch (e) {
    print('Error launching email: $e');
  }
}
