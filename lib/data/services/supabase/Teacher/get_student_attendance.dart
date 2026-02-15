import 'package:supabase_flutter/supabase_flutter.dart';

class GetStudentAttendance {
  final client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getStudentAttendanceBySubject(
    String rollNo,
    int subjectId,
  ) async {
    try {
      final response = await client
          .from('attendance_logs')
          .select()
          .eq('roll_no', rollNo)
          .eq('subject_id', subjectId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTeacherSubjects(int employeeId) async {
    try {
      final response = await client
          .from('subjects')
          .select()
          .eq('employee_id', employeeId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  Future<Map<String, int>> getAttendanceStats(
    String rollNo,
    int subjectId,
  ) async {
    final records = await getStudentAttendanceBySubject(rollNo, subjectId);
    final total = records.length;
    final present = total;
    final absent = 0;

    return {
      'present': present,
      'absent': absent,
      'total': total,
      'percentage': total > 0 ? ((present / total) * 100).toInt() : 0,
    };
  }
}
