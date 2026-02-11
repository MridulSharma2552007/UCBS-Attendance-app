import 'package:supabase_flutter/supabase_flutter.dart';

class FetchStudyMaterial {
  final client = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> fetchStudyMaterual() async {
    final response = await client.from('study_material').select('*');
    print(response);
    return response;
  }
}
