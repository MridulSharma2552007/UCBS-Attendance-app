import 'package:supabase_flutter/supabase_flutter.dart';

class MarkAttendance {
  final client = Supabase.instance.client;

  Future<void> markAttendance(String roll_no, int sem, String subject) async {
    final response = await client.from('attendance_logs').insert({
      'roll_no': roll_no,
      'sem': sem,
      'subject': subject,
    });
    print(response);
  }
}
