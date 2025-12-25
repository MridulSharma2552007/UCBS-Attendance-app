import 'package:supabase_flutter/supabase_flutter.dart';

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
      });
    } on PostgrestException catch (e) {
      throw Exception("Supabase insert failed: ${e.message}");
    } catch (e) {
      throw Exception("Unknown Supabase error: $e");
    }
  }
}
