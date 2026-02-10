import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

class ProfileScreenStudent extends StatelessWidget {
  const ProfileScreenStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudentTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [_buildProfileHeader(context), SizedBox(height: 40)],
        ),
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
    print('Email URI: $emailUri');
    print('Can launch: ${await canLaunchUrl(emailUri)}');
    await launchUrl(emailUri);
  } catch (e) {
    print('Error launching email: $e');
  }
}

Widget _buildProfileAvatat() {
  final user = FirebaseAuth.instance.currentUser;
  final photoUrl = user?.photoURL;

  return Container(
    height: 150,
    width: 150,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.bgDark,
      image: photoUrl != null
          ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
          : null,
    ),
    child: photoUrl == null
        ? Icon(Icons.person, size: 80, color: Colors.white)
        : null,
  );
}
