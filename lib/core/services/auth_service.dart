import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/core/constants/app_constants.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';
import 'package:ucbs_attendance_app/data/services/Firebase/sign_in_with_google.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';
import 'package:ucbs_attendance_app/presentation/screens/login/Shared/login.dart';

class AuthService {
  static final _googleAuth = SignInWithGoogle();
  static Future<void> signIn(BuildContext context) async {
    final SupabaseClient = Supabase.instance.client;
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
