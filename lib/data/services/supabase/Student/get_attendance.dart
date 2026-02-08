import 'package:supabase_flutter/supabase_flutter.dart';

class GetAttendance {
  final client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getAttendanceStream(String roll_no) {
    return client
        .from('attendance_logs')
        .stream(primaryKey: ['id'])
        .map(
          (data) => List<Map<String, dynamic>>.from(
            data,
          ).where((item) => item['roll_no'] == roll_no).toList(),
        )
        .asBroadcastStream()
        .handleError((error) {
          print('Error in attendance stream: $error');
        });
  }
}
