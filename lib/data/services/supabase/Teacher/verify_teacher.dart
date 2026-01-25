import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyTeacher {
  final _client = Supabase.instance.client;

  Future<void> pushTeacherData({
    required String email,
    required String name,
    required int id,
    required List<double> vector,
    required double confidence,
  }) async {
    try {
      await _client.from('teachers').insert({
        'employee_id': id,
        'email': email,
        'name': name,
        'face_vector': vector,
        'confidence': confidence,
      });
    } on PostgrestException catch (e) {
      throw Exception("Supabase insert failed: ${e.message}");
    } catch (e) {
      throw Exception("Unknown Supabase error: $e");
    }
  }

  Future<bool> checkTeacherIDExistance(String id) async {
    try {
      final response = await _client
          .from('teachers')
          .select('employee_id')
          .eq('employee_id', int.parse(id))
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTeacherData(String email) async {
    try {
      final response = await _client
          .from('teachers')
          .select('id, employee_id, name, email, subject, face_vector, created_at')
          .eq('email', email)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching teacher data: $e');
      return null;
    }
  }
}
