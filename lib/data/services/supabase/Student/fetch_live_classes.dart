import 'package:supabase_flutter/supabase_flutter.dart';

class FetchLiveClasses {
  final client = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> fetchLiveClasses() async {
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
