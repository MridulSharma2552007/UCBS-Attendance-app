import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';

class SearchStudent extends StatefulWidget {
  const SearchStudent({super.key});

  @override
  State<SearchStudent> createState() => _SearchStudentState();
}

class _SearchStudentState extends State<SearchStudent> {
  TextEditingController _searchController = TextEditingController();

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
            _buildSearchField(_searchController),
          ],
        ),
      ),
    );
  }
}

Widget _buildSearchField(TextEditingController controller) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border.all(color: StudentTheme.cardcolor.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search for Other Students By Roll No...',
        border: InputBorder.none,
        icon: Icon(Icons.search, color: StudentTheme.cardcolor),
      ),
    ),
  );
}
