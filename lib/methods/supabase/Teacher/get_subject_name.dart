import 'package:supabase_flutter/supabase_flutter.dart';

class GetSubjectName {
  final supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    final response = await supabase
        .from('subjects')
        .select()
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
}
