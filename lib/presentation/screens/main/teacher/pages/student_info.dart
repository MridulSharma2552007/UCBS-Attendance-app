import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

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
            // Profile Card
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

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Present',
                    '42',
                    Icons.check_circle,
                    const Color(0xFF00D9A3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Absent',
                    '8',
                    Icons.cancel,
                    const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Rate',
                    '84%',
                    Icons.trending_up,
                    const Color(0xFFFFD93D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    '50',
                    Icons.calendar_today,
                    const Color(0xFFB794F6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Subject Performance
            Text(
              'Subject Performance',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildSubjectCard('Mathematics', 92, const Color(0xFFCDFF5C)),
            _buildSubjectCard('Physics', 88, const Color(0xFFFFD93D)),
            _buildSubjectCard('Chemistry', 76, const Color(0xFFFF8A65)),
            _buildSubjectCard('English', 95, const Color(0xFF6EC6FF)),
            _buildSubjectCard('Computer Science', 90, const Color(0xFFDDA0DD)),

            const SizedBox(height: 28),

            // Weekly Overview
            Text(
              'This Week',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayCard('M', true),
                _buildDayCard('T', true),
                _buildDayCard('W', true),
                _buildDayCard('T', false),
                _buildDayCard('F', true),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(String subject, int percentage, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(String day, bool present) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            present ? Icons.check_circle : Icons.cancel,
            color: present ? const Color(0xFF00D9A3) : const Color(0xFFFF6B6B),
            size: 24,
          ),
        ],
      ),
    );
  }
}
