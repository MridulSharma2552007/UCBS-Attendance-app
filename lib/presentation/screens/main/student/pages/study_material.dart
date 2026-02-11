import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Student/fetch_study_material.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';

class StudyMaterial extends StatefulWidget {
  const StudyMaterial({super.key});

  @override
  State<StudyMaterial> createState() => _StudyMaterialState();
}

class _StudyMaterialState extends State<StudyMaterial> {
  bool isLoading = true;
  final FetchStudyMaterial fetchStudyMaterial = FetchStudyMaterial();
  List<Map<String, dynamic>> studyMaterial = [];

  @override
  void initState() {
    super.initState();
    _fetchMaterial();
  }

  Future<void> _fetchMaterial() async {
    studyMaterial = await fetchStudyMaterial.fetchStudyMaterual();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudentTheme.backgroundColor,
      body: isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 32),
                  _buildStatsRow(),
                  SizedBox(height: 32),
                  _buildMaterialList(),
                  SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: StudentTheme.primarypink),
          SizedBox(height: 16),
          Text(
            'Loading materials...',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Study Materials',
              style: GoogleFonts.dmSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => isLoading = true);
                _fetchMaterial();
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.refresh,
                  color: StudentTheme.primarypink,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Explore comprehensive learning resources',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.library_books_rounded,
            label: 'Total Materials',
            value: '${studyMaterial.length}',
            color: StudentTheme.primarypink,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.category_rounded,
            label: 'Categories',
            value: '${_getUniqueCategories().length}',
            color: StudentTheme.accentcoral,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialList() {
    if (studyMaterial.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.library_books_rounded,
                size: 56,
                color: Colors.black12,
              ),
              SizedBox(height: 16),
              Text(
                'No materials available',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Resources',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        ...studyMaterial.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> material = entry.value;
          return _buildMaterialCard(material, index);
        }).toList(),
      ],
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material, int index) {
    final title = material['title'] ?? 'Untitled';
    final description = material['description'] ?? 'No description';
    final category = material['category'] ?? 'General';
    final fileUrl = material['url'] ?? '';
    final fileType = _getFileType(fileUrl);
    final colors = [
      StudentTheme.primarypink,
      StudentTheme.accentcoral,
      Color(0xff4ECDC4),
      Color(0xffFFE66D),
    ];
    final color = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getFileIcon(fileType), color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.file_present_rounded,
                          size: 14,
                          color: Colors.black38,
                        ),
                        SizedBox(width: 6),
                        Text(
                          fileType.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: fileUrl.isEmpty
                          ? null
                          : () async {
                              await launchUrl(Uri.parse(fileUrl),
                                  mode: LaunchMode.externalApplication);
                            },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: fileUrl.isEmpty
                              ? Colors.grey.withOpacity(0.15)
                              : color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: fileUrl.isEmpty
                                ? Colors.grey.withOpacity(0.3)
                                : color.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              fileUrl.isEmpty ? 'N/A' : 'View',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: fileUrl.isEmpty ? Colors.grey : color,
                              ),
                            ),
                            if (fileUrl.isNotEmpty) ...[
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: color,
                              ),
                            ],
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
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'video':
      case 'mp4':
        return Icons.video_library_rounded;
      case 'image':
      case 'jpg':
      case 'png':
        return Icons.image_rounded;
      default:
        return Icons.file_present_rounded;
    }
  }

  String _getFileType(String url) {
    if (url.isEmpty) return 'file';
    final extension = url.split('.').last.toLowerCase();
    return extension;
  }

  List<String> _getUniqueCategories() {
    final categories = <String>{};
    for (var material in studyMaterial) {
      categories.add(material['category'] ?? 'General');
    }
    return categories.toList();
  }
}

class FileViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const FileViewerScreen({required this.url, required this.title});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  @override
  void initState() {
    super.initState();
    launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold();
}
