import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartClass extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;

  const StartClass({super.key, required this.subjects});

  @override
  State<StartClass> createState() => _StartClassState();
}

class _StartClassState extends State<StartClass> {
  bool isClassLive = false;
  Future<void> EndClass() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getInt('employee_id');
    if (employeeId == null) {
      throw Exception("Employee ID not found In DB");
    }

    final client = Supabase.instance.client;
    final response = await client
        .from('live_class')
        .delete()
        .eq('teacher_id', employeeId);
    setState(() {
      isClassLive = false;
    });
  }

  Future<void> StartClass() async {
    HapticFeedback.mediumImpact();
    final subject = widget.subjects.first;
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getInt('employee_id');
    if (employeeId == null) {
      throw Exception("Employee ID not found In DB");
    }

    final client = Supabase.instance.client;
    final response = await client.from('live_class').insert({
      'teacher_id': employeeId,
      'subjectName': subject['name'],
      'sem': subject['sem'],
    });
    setState(() {
      isClassLive = true;
    });
  }

  Map<String, dynamic> get subject => widget.subjects.first;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Class Session',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Semester ${subject['sem']}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isClassLive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isClassLive ? 'Class is live' : 'Class not started',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Center(
                child: Text(
                  '00 : 00 : 00',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 42,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const Spacer(),
              if (!isClassLive)
                GestureDetector(
                  onTap: () {
                    StartClass();
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: const Center(
                      child: Text(
                        'Start Class',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  EndClass();
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'End Class',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
