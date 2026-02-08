import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';

class WeeklyAttendanceChart extends StatefulWidget {
  final List<Map<String, dynamic>>? attendanceData;

  const WeeklyAttendanceChart({super.key, this.attendanceData});

  @override
  State<WeeklyAttendanceChart> createState() => _WeeklyAttendanceChartState();
}

class _WeeklyAttendanceChartState extends State<WeeklyAttendanceChart> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  @override
  void didUpdateWidget(WeeklyAttendanceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    final groupedData = _groupByDate();
    final days = groupedData.keys.toList();
    final today = DateTime.now();
    final todayKey = '${today.day} ${_getMonth(today.month)}';
    
    final todayIndex = days.indexOf(todayKey);
    if (todayIndex != -1 && _scrollController.hasClients) {
      final offset = (todayIndex * 80.0) - 120.0;
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, double> _groupByDate() {
    if (widget.attendanceData == null || widget.attendanceData!.isEmpty) {
      return {};
    }
    final grouped = <String, double>{};
    for (var item in widget.attendanceData!) {
      final date = DateTime.parse(item['created_at']);
      final key = '${date.day} ${_getMonth(date.month)}';
      grouped[key] = (grouped[key] ?? 0) + (item['sem'] ?? 0).toDouble();
    }
    return grouped;
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupByDate();
    final days = groupedData.keys.toList();
    final heights = groupedData.values.toList();
    final totalAttendance = heights.fold(0.0, (sum, val) => sum + val).toInt();
    final chartWidth = (days.length * 80.0).clamp(300.0, double.infinity);

    return Column(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Container(
            width: chartWidth,
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 5.0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= days.length) return SizedBox.shrink();
                        return Text(
                          days[index],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.7),
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
                  days.isEmpty ? 1 : days.length,
                  (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: heights.isEmpty ? 0 : heights[index],
                          color: StudentTheme.accentcoral,
                          width: 50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL ATTENDANCE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.4),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$totalAttendance Classes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF00D9A3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${days.length} Days',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Color(0xFF00D9A3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MONTHLY GOAL',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.4),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '85%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: StudentTheme.accentcoral,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '2.5% -3.4%',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: StudentTheme.accentcoral,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
