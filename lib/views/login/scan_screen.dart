import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ucbs_attendance_app/methods/supabase/verified_student.dart';
import 'package:ucbs_attendance_app/methods/supabase/verify_teacher.dart';
import 'package:ucbs_attendance_app/provider/user_session.dart';
import 'package:ucbs_attendance_app/views/main/student/home.dart';
import 'package:ucbs_attendance_app/views/main/teacher/teacher_home.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _loading = true;
  bool _uploading = false;

  double? personConfidence;
  bool embeddingCaptured = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) return;

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (!mounted) return;

    setState(() => _loading = false);
  }

  Future<void> _sendImage(String path) async {
    final userdata = context.read<UserSession>();
    List<double>? faceVector;
    try {
      setState(() => _uploading = true);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("https://nida-untutelar-lustrelessly.ngrok-free.dev/detect"),
      );

      request.files.add(await http.MultipartFile.fromPath('file', path));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final decoded = jsonDecode(body);

      final detections = decoded['detections'] as List;

      double? conf;
      bool hasEmbedding = false;

      for (final d in detections) {
        if (d['object'] == 'person') {
          conf = (d['confidence'] as num).toDouble();

          if (d['embedding'] != null) {
            faceVector = List<double>.from(d['embedding']);
            hasEmbedding = true;
          }

          break;
        }
      }

      setState(() {
        personConfidence = conf;
        embeddingCaptured = hasEmbedding;
        _uploading = false;
      });

      if (conf == null || conf < 0.50 || !hasEmbedding || faceVector == null) {
        debugPrint("Face not valid for attendance");
        return;
      }

      if (userdata.role == "Student") {
        await VerifiedStudent().pushStudentData(
          email: userdata.email!,
          name: userdata.name!,
          rollNo: userdata.rollNo!,
          sem: userdata.sem!,
          vector: faceVector,
          confidence: conf,
        );
      }

      if (userdata.role == "Teacher") {
        await VerifyTeacher().pushTeacherData(
          email: userdata.email!,
          name: userdata.name!,
          vector: faceVector,
          confidence: conf,
        );
      }

      if (!mounted) return;

      await Future.delayed(const Duration(seconds: 2));
      _controller?.dispose();
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => userdata.role == "Teacher" ? TeacherHome() : Home(),
        ),
      );
    } catch (e) {
      debugPrint("Upload error: $e");
      setState(() => _uploading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),

          Positioned(top: 40, left: 20, right: 20, child: InstructionCard()),

          if (personConfidence != null)
            Positioned(
              bottom: 140,
              left: 20,
              right: 20,
              child: ResultCard(
                confidence: personConfidence!,
                hasEmbedding: embeddingCaptured,
              ),
            ),

          /// CAPTURE BUTTON
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.mediumImpact();

                  if (_controller!.value.isInitialized) {
                    final file = await _controller!.takePicture();
                    await _sendImage(file.path);
                  }
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// UPLOADING LOADER
          if (_uploading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}

class InstructionCard extends StatelessWidget {
  const InstructionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: const TypingText(
            text:
                "⚠ FACE SCAN INSTRUCTIONS\n\n"
                "• Keep your face inside the frame\n"
                "• Look straight at the camera\n"
                "• Avoid backlight\n"
                "• Hold still for 1–2 seconds\n"
                "• AI captures 512-D facial vector",
          ),
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final double confidence;
  final bool hasEmbedding;

  const ResultCard({
    super.key,
    required this.confidence,
    required this.hasEmbedding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              Text(
                "Person confidence: ${(confidence * 100).toStringAsFixed(2)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasEmbedding
                    ? "✔ Face embedding captured (512-D)"
                    : "⚠ Face not clear enough",
                style: TextStyle(
                  color: hasEmbedding
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= TYPING TEXT =================

class TypingText extends StatefulWidget {
  final String text;

  const TypingText({super.key, required this.text});

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String current = "";
  int index = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      if (index < widget.text.length) {
        setState(() => current += widget.text[index]);
        HapticFeedback.selectionClick();
        index++;
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      current,
      style: const TextStyle(color: Colors.white, height: 1.4),
    );
  }
}
