import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ucbs_attendance_app/data/services/supabase/Teacher/search_student.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';

class SearchStudent extends StatefulWidget {
  const SearchStudent({super.key});

  @override
  State<SearchStudent> createState() => _SearchStudentState();
}

class _SearchStudentState extends State<SearchStudent>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  final SearchStudentService _searchService = SearchStudentService();
  bool isLoading = false;
  bool hasSearched = false;
  late Map<int, AnimationController> _flipControllers = {};
  late Map<int, bool> _isFlipped = {};

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _flipControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> searchStudent() async {
    if (_searchController.text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      isLoading = true;
      hasSearched = true;
    });
    try {
      final results = await _searchService.searchByRollNo(
        _searchController.text,
      );
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'We are working hard to get this feature to you!',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: StudentTheme.primarypink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleFlip(int index) {
    if (!_flipControllers.containsKey(index)) {
      _flipControllers[index] = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      );
      _isFlipped[index] = false;
    }

    if (_isFlipped[index]!) {
      _flipControllers[index]!.reverse();
    } else {
      _flipControllers[index]!.forward();
    }
    _isFlipped[index] = !_isFlipped[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudentTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Text(
              'Discovery',
              style: GoogleFonts.inter(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            _buildSearchField(_searchController, searchStudent),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: isLoading ? 5 : searchResults.length,
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return _buildSkeletonCard();
                  }
                  final student = searchResults[index];
                  return _buildStudentCard(student, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    if (!_flipControllers.containsKey(index)) {
      _flipControllers[index] = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      );
      _isFlipped[index] = false;
    }

    final controller = _flipControllers[index]!;
    final animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return GestureDetector(
      onTap: () => _toggleFlip(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final angle = animation.value * 3.14159;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle);
            final isFront = animation.value < 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: transform,
              child: isFront
                  ? _buildFrontCard(student)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildBackCard(student),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontCard(Map<String, dynamic> student) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                            Icon(Icons.person, size: 14, color: Colors.black87),
                            SizedBox(width: 6),
                            Text(
                              "Sem ${student['semester'] ?? 'N/A'}",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        student['roll_no'] ?? 'N/A',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        student['name'] ?? 'Unknown',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Tap to flip',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.black38,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Roll Number',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        student['roll_no'] ?? 'N/A',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _showComingSoon,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'MESSAGE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackCard(Map<String, dynamic> student) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Contact Info',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Email',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          student['email'] ?? 'N/A',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Tap to flip back',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.black38,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
              height: 80,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                height: 140,
              ),
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: StudentTheme.accentcoral,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                height: 80,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildSearchField(
  TextEditingController controller,
  VoidCallback onSubmitted,
) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border.all(color: StudentTheme.cardcolor.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: TextField(
      onSubmitted: (value) => onSubmitted(),
      keyboardType: TextInputType.numberWithOptions(
        signed: false,
        decimal: false,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        hintText: 'Search for Other Students By Roll No...',
        border: InputBorder.none,
        icon: Icon(Icons.search, color: StudentTheme.cardcolor),
      ),
    ),
  );
}
