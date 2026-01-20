import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';
import 'package:ucbs_attendance_app/views/main/teacher/pages/student_info.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  bool hasSearched = false;
  final client = Supabase.instance.client;
  List<Map<String, dynamic>> searchResults = [];
  
  Future<void> searchuser() async {
    if (_searchController.text.isEmpty) {
      return;
    }
    
    setState(() {
      isLoading = true;
      hasSearched = true;
    });
    
    HapticFeedback.lightImpact();
    
    try {
      final response = await client
          .from('students')
          .select()
          .eq('roll_no', _searchController.text);
      
      setState(() {
        searchResults = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: PageView(
          controller: _pageController,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Student',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Find student by roll number',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _searchController,
                    onSubmitted: (value) => searchuser(),
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter roll number...',
                      hintStyle: GoogleFonts.dmSans(
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchResults = [];
                                  hasSearched = false;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : searchuser,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Search Student',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Expanded(
                  child: _buildSearchResults(),
                ),
              ],
            ),
            StudentInfo(studentData: searchResults),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchResults() {
    if (!hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a student',
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a roll number to find student details',
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }
    
    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No student found',
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No student with roll number "${_searchController.text}" was found',
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
    
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final student = searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.lightImpact();
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.blue.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          student['name'][0].toString().toUpperCase(),
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
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
                            style: GoogleFonts.dmSans(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Roll No: ${student['roll_no']}',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Semester ${student['semester']}',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
