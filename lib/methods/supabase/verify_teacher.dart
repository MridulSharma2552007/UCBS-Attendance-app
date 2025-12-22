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
}
