import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class StartClass extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  const StartClass({super.key, required this.subjects});

  @override
  State<StartClass> createState() => _StartClassState();
}

class _StartClassState extends State<StartClass> {
  DateTime? classStartTime;
  Duration elapsedTime = Duration.zero;
  Timer? _timer;
  bool isClassLive = false;
  bool showEndButton = false;
  bool isLoadingTime = true;
  void startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (classStartTime == null) {
        timer.cancel();
        return;
      }

      setState(() {
        elapsedTime = DateTime.now().difference(classStartTime!);
      });
    });
  }

  Future<void> showEndBtn() async {
    final client = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getInt('employee_id');
    if (employeeId == null) {
      throw Exception("Employee ID not found In DB");
    }
    final response = await client
        .from('live_class')
        .select()
        .eq('teacher_id', employeeId)
        .eq('subjectName', subject['name'])
        .eq('is_activated', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response != null) {
      classStartTime = DateTime.parse(response['created_at']).toLocal();

      setState(() {
        showEndButton = true;
        isClassLive = true;
        isLoadingTime = false;
      });

      startTimer();
    } else {
      setState(() {
        showEndButton = false;
        isClassLive = false;
        elapsedTime = Duration.zero;
        classStartTime = null;
        isLoadingTime = false;
      });
    }
  }

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
        .update({'is_activated': false})
        .eq('teacher_id', employeeId)
        .eq('subjectName', subject['name']);
    setState(() {
      isClassLive = false;
      showEndButton = false;
      elapsedTime = Duration.zero;
      classStartTime = null;
    });

    // Navigate back and refresh the main page
    Navigator.pop(context, true);
  }

  Future<void> StartClass() async {
    final client = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getInt('employee_id');
    if (employeeId == null) {
      throw Exception("Employee ID not found In DB");
    }
    final check = await client
        .from('live_class')
        .select()
        .eq('teacher_id', employeeId)
        .eq('is_activated', true)
        .maybeSingle();
    if (check != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "A class is already live. End it before starting a new one.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final subject = widget.subjects.first;

    await client.from('live_class').insert({
      'teacher_id': employeeId,
      'subjectName': subject['name'],
      'sem': subject['sem'],
      'is_activated': true,
    });
    classStartTime = DateTime.now();
    setState(() {
      isClassLive = true;
      showEndButton = true;
      isLoadingTime = false;
    });
    startTimer();
  }

  String formatDuration(Duration d) {
    if (d.isNegative) {
      d = d.abs();
    }

    String two(int n) => n.toString().padLeft(2, '0');

    final h = two(d.inHours);
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));

    return "$h:$m:$s";
  }

  Map<String, dynamic> get subject => widget.subjects.first;
  @override
  void initState() {
    super.initState();
    showEndBtn();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1A1A1A), const Color(0xFF2A2A2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.book,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isClassLive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isClassLive
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isClassLive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isClassLive ? 'Class is Live' : 'Class Inactive',
                      style: TextStyle(
                        color: isClassLive ? Colors.green : Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isLoadingTime
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white60,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Calculating time...',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            formatDuration(elapsedTime),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            ),
                          ),
                  ],
                ),
              ),

              const Spacer(),

              if (!isClassLive)
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.greenAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: StartClass,
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Start Class',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              if (showEndButton && isClassLive)
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: EndClass,
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.stop, color: Colors.redAccent, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'End Class',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else if (!isClassLive)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Start a class to begin attendance tracking',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
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
