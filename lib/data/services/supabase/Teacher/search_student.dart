import 'package:supabase_flutter/supabase_flutter.dart';

class SearchStudentService {
  final client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> searchByRollNo(String rollNo) async {
    if (rollNo.isEmpty) return [];

    try {
      final response = await client
          .from('students')
          .select()
          .eq('roll_no', rollNo);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
}
