import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/core/constants/app_constants.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';
import 'package:ucbs_attendance_app/data/services/Firebase/sign_in_with_google.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';
import 'package:ucbs_attendance_app/presentation/screens/login/Shared/login.dart';
import 'package:ucbs_attendance_app/presentation/screens/login/Teacher/sign_in_teacher.dart';

class AuthService {
  static final _googleAuth = SignInWithGoogle();
  static Future<void> SignInStudent(
    BuildContext context,
    Map<String, dynamic> studentData,
  ) async {
    try {
      debugPrint('SignInStudent called with: $studentData');

      // Store data in SharedPreferences
      await StorageService.setString('userEmail', studentData['email']);
      await StorageService.setString(
        AppConstants.userNameKey,
        studentData['name'],
      );
      await StorageService.setString(
        'roll_no',
        studentData['roll_no'].toString(),
      );
      await StorageService.setInt(
        'semester',
        int.parse(studentData['semester'].toString()),
      );
      await StorageService.setString(
        AppConstants.roleKey,
        AppConstants.studentRole,
      );
      await StorageService.setBool(AppConstants.isLoggedKey, true);

      debugPrint('Student data saved to prefs');

      // Update provider
      if (context.mounted) {
        context.read<UserSession>().setEmail(studentData['email']);
        context.read<UserSession>().setName(studentData['name']);
        context.read<UserSession>().setrole(AppConstants.studentRole);
      }
    } catch (e) {
      debugPrint("Sign in error: $e");
      rethrow;
    }
  }

  static Future<void> SignInTeacher(
    BuildContext context,
    Map<String, dynamic> teacherData,
  ) async {
    try {
      // Store data in SharedPreferences
      await StorageService.setString('userEmail', teacherData['email']);
      await StorageService.setString(
        AppConstants.userNameKey,
        teacherData['name'],
      );
      await StorageService.setInt(
        AppConstants.employeeIdKey,
        teacherData['employee_id'],
      );
      await StorageService.setString(
        AppConstants.roleKey,
        AppConstants.teacherRole,
      );
      await StorageService.setBool(AppConstants.isLoggedKey, true);

      // Update provider
      if (context.mounted) {
        context.read<UserSession>().setEmail(teacherData['email']);
        context.read<UserSession>().setName(teacherData['name']);
        context.read<UserSession>().setrole(AppConstants.teacherRole);
      }
    } catch (e) {
      debugPrint("Sign up error: $e");
      rethrow;
    }
  }

  // Sign Out Function
  static Future<void> signOut(BuildContext context) async {
    try {
      // Clear Google Auth
      await _googleAuth.signOut();

      // Clear all stored data
      await StorageService.remove(AppConstants.isLoggedKey);
      await StorageService.remove(AppConstants.roleKey);
      await StorageService.remove(AppConstants.employeeIdKey);
      await StorageService.remove(AppConstants.userNameKey);
      await StorageService.remove('userEmail');

      // Clear provider data
      if (context.mounted) {
        context.read<UserSession>().clear();
      }

      // Navigate to login
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Login()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return StorageService.getBool(AppConstants.isLoggedKey) ?? false;
  }

  // Get current user role
  static String? getCurrentRole() {
    return StorageService.getString(AppConstants.roleKey);
  }

  // Get current user data
  static Map<String, dynamic> getCurrentUserData() {
    return {
      'isLogged': StorageService.getBool(AppConstants.isLoggedKey) ?? false,
      'role': StorageService.getString(AppConstants.roleKey),
      'userName': StorageService.getString(AppConstants.userNameKey),
      'employeeId': StorageService.getInt(AppConstants.employeeIdKey),
      'userEmail': StorageService.getString('userEmail'),
    };
  }
}
