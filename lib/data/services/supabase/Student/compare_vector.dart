import 'package:supabase_flutter/supabase_flutter.dart';

class CompareVector {
  final client = Supabase.instance.client;

  Future<void> putScannedVector(String roll_no, String vector) async {
    await client.from('scan_outputs').insert({
      'roll_no': roll_no,
      'face_vector': vector,
    });
  }

  Future<bool> compareFaceVectors(String rollNo) async {
    try {
      final result =
          await client.rpc(
                'compare_student_vectors',
                params: {'student_roll_no': rollNo},
              )
              as List<dynamic>;

      if (result.isEmpty) {
        print('❌ No result returned');
        await _cleanupScanOutput(rollNo);
        return false;
      }

      final similarity = (result[0]['similarity_percentage'] as num).toDouble();
      print('📊 Similarity: $similarity%');

      // Cleanup scan_outputs after comparison
      await _cleanupScanOutput(rollNo);

      return similarity > 70;
    } catch (e) {
      print('❌ Compare error: $e');
      await _cleanupScanOutput(rollNo);
      return false;
    }
  }

  Future<void> _cleanupScanOutput(String rollNo) async {
    try {
      await client.from('scan_outputs').delete().eq('roll_no', rollNo);
      print('🗑️ Cleaned up scan_outputs for $rollNo');
    } catch (e) {
      print('⚠️ Cleanup error: $e');
    }
  }
}
