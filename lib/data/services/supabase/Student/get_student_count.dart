import 'package:supabase_flutter/supabase_flutter.dart';

class GetStudentCount {
  final client = Supabase.instance.client;

  // Stream that emits the count of students in a class
  Stream<int> getStudentCountStream(int classId) {
    return client
        .from('attendance_logs')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data)
            .where((item) => item['subject_id'] == classId)
            .length)
        .asBroadcastStream()
        .handleError((error) {
          print('Error in student count stream: $error');
        });
  }
}
