import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';

class VerifiedStudent {
  final _client = Supabase.instance.client;

  Future<void> pushStudentData({
    required String email,
    required String name,
    required String rollNo,
    required String sem,
    required List<double> vector,
    required double confidence,
  }) async {
    try {
      await _client.from('students').insert({
        'email': email,
        'name': name,
        'roll_no': rollNo,
        'semester': sem,
        'face_vector': vector,
        'confidence': confidence,
        'fcm': StorageService.getString('fcm_token') ?? '',
      });
    } on PostgrestException catch (e) {
      throw Exception("Supabase insert failed: ${e.message}");
    } catch (e) {
      throw Exception("Unknown Supabase error: $e");
    }
  }

  Future<bool> isRollNoExists(String rollNo) async {
    try {
      final response = await _client
          .from('students')
          .select('roll_no')
          .eq('roll_no', rollNo)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getStudentData(String email) async {
    try {
      final response = await _client
          .from('students')
          .select()
          .eq('email', email)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }
}
