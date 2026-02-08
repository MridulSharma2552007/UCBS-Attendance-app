import 'package:supabase_flutter/supabase_flutter.dart';

class FetchLiveClasses {
  final client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> fetchLiveClassesStream() {
    return client
        .from('live_class')
        .stream(primaryKey: ['id'])
        .map(
          (data) => List<Map<String, dynamic>>.from(
            data,
          ).where((item) => item['is_activated'] == true).toList(),
        )
        .asBroadcastStream()
        .handleError((error) {
          print('Error in live classes stream: $error');
        });
  }

  Future<List<Map<String, dynamic>>> fetchLiveClassesFuture() async {
    try {
      final response = await client
          .from('live_class')
          .select()
          .eq('is_activated', true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching live classes: $e');
      return [];
    }
  }
}
