import 'package:supabase_flutter/supabase_flutter.dart';

class GetAttendance {
  final client = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> getAttendance(String roll_no) async {
    final response = await client
        .from('attendance_logs')
        .select()
        .eq('roll_no', roll_no);
    return response;
  }
}
