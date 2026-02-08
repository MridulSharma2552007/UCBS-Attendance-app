import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Student/fetch_live_classes.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Student/get_attendance.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/pages/location_screen.dart';
import 'package:ucbs_attendance_app/presentation/widgets/charts/weekly_attendance_chart.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen>
    with WidgetsBindingObserver {
  late FetchLiveClasses _liveClassesService;
  late GetAttendance _attendanceService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _liveClassesService = FetchLiveClasses();
    _attendanceService = GetAttendance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refreshClasses() async {
    await _liveClassesService.fetchLiveClassesFuture();
    setState(() {});
  }

  Widget _buildSkeletonLoader() {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: StudentTheme.primarypink.withOpacity(0.15),
        borderRadius: BorderRadius.circular(32),
      ),
      height: 180,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudentTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            _buildHeader(),
            SizedBox(height: 40),
            _buildAttendanceChart(),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Classes.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: _refreshClasses,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.refresh, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLiveClassesStream(),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _attendanceService.getAttendanceStream(
        StorageService.getString('roll_no')!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: StudentTheme.primarypink.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }

        final attendanceData = snapshot.data ?? [];
        return WeeklyAttendanceChart(attendanceData: attendanceData);
      },
    );
  }

  Widget _buildLiveClassesStream() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _liveClassesService.fetchLiveClassesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: List.generate(2, (_) => _buildSkeletonLoader()),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading classes'));
        }

        final liveClasses = snapshot.data ?? [];

        if (liveClasses.isEmpty) {
          return Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.class_, size: 48, color: Colors.black26),
                  SizedBox(height: 12),
                  Text(
                    'No live classes.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildClassesList(liveClasses);
      },
    );
  }

  Widget _buildClassesList(List<Map<String, dynamic>> liveClasses) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _attendanceService.getAttendanceStream(
        StorageService.getString('roll_no')!,
      ),
      builder: (context, attendanceSnapshot) {
        final attendanceData = attendanceSnapshot.data ?? [];
        final joinedClassIds = Set<int>.from(
          attendanceData.map((item) => item['subject_id'] as int),
        );

        return Column(
          children: liveClasses.map((classData) {
            final isJoined = joinedClassIds.contains(classData['id']);

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.science,
                                        size: 14,
                                        color: Colors.black87,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Sem ${classData['sem']}",
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      classData['sem'] == 1
                                          ? 'Rm 101'
                                          : classData['sem'] == 2
                                          ? 'Rm 101'
                                          : classData['sem'] == 3
                                          ? 'Rm 201'
                                          : classData['sem'] == 4
                                          ? 'Rm 201'
                                          : classData['sem'] == 5
                                          ? 'Rm 301'
                                          : 'Rm 601',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Icon(
                                      Icons.expand_more,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Subject',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        classData['subjectName'] ??
                                            'Subject Name',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Started at',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.black38,
                                      ),
                                    ),
                                    Text(
                                      DateTime.parse(
                                        classData['created_at'],
                                      ).toLocal().toString().substring(11, 16),
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: StudentTheme.accentcoral,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'LIVE NOW',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.menu,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Attendance Tracking',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '84% Presence',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isJoined
                                      ? null
                                      : () {
                                          final studentSem =
                                              StorageService.getInt('semester');
                                          if (studentSem != classData['sem']) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor:
                                                    Colors.grey[900],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                title: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors.orange,
                                                      size: 28,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Not Enrolled',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: Text(
                                                  'You are not enrolled in Semester ${classData['sem']}. Please contact admin to update your semester.',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                      'OK',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            if (classData['subjectName'] !=
                                                null) {
                                              context
                                                  .read<UserSession>()
                                                  .selectedClass(
                                                    classData['subjectName'],
                                                    classData['id'],
                                                  );
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LocationScreen(),
                                              ),
                                            );
                                          }
                                        },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isJoined
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isJoined
                                            ? Colors.green
                                            : Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isJoined)
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 14,
                                          ),
                                        if (isJoined) SizedBox(width: 4),
                                        Text(
                                          isJoined ? 'JOINED' : 'FAST JOIN',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isJoined
                                                ? Colors.green
                                                : Colors.white,
                                            letterSpacing: 1.2,
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
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: StudentTheme.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: StudentTheme.backgroundColor,
                        width: 4,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sync_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

Widget _buildHeader() {
  final String studentname = StorageService.getString('UserName')!;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hello, $studentname!👋',
            style: GoogleFonts.dmSans(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StudentTheme.cardcolor,
              image: FirebaseAuth.instance.currentUser?.photoURL != null
                  ? DecorationImage(
                      image: NetworkImage(
                        FirebaseAuth.instance.currentUser!.photoURL!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
        ],
      ),
      Text(
        'Your attendance for today',
        style: GoogleFonts.dmSans(fontSize: 20, color: AppColors.textFaded),
      ),
    ],
  );
}
