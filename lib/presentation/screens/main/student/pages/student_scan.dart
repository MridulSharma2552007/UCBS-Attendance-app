import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ucbs_attendance_app/core/constants/app_constants.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Student/compare_vector.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Student/mark_attendance.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

// Web-specific imports
import 'package:ucbs_attendance_app/presentation/widgets/web/web_camera_widget.dart'
    if (dart.library.io) 'package:ucbs_attendance_app/presentation/widgets/web/web_camera_stub.dart';
import 'package:ucbs_attendance_app/presentation/screens/login/Shared/web_helper.dart'
    if (dart.library.io) 'package:ucbs_attendance_app/presentation/screens/login/Shared/web_helper_stub.dart';

class StudentScan extends StatefulWidget {
  const StudentScan({super.key});

  @override
  State<StudentScan> createState() => _StudentScanState();
}

class _StudentScanState extends State<StudentScan> {
  CameraController? _controller;
  bool _loading = true;
  bool _uploading = false;
  dynamic _videoElement;
  bool _webCameraReady = false;

  double? personConfidence;
  bool embeddingCaptured = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (kIsWeb) {
      await _initWebCamera();
    } else {
      await _initMobileCamera();
    }
  }

  Future<void> _initWebCamera() async {
    setState(() => _loading = false);
  }

  void _onWebVideoReady(dynamic video) {
    _videoElement = video;
    setState(() => _webCameraReady = true);
  }

  Future<void> _initMobileCamera() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      setState(() => _loading = false);
      return;
    }

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
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
    List<double>? faceVector;
    try {
      setState(() => _uploading = true);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConstants.detectEndpoint),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Face not clear enough. Please try again."),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      await _processDetection(faceVector, conf);
    } catch (e) {
      debugPrint("Upload error: $e");
      setState(() => _uploading = false);
      if (mounted) {
        _showServerErrorDialog();
      }
    }
  }

  Future<void> _captureWebImage() async {
    if (!kIsWeb || _videoElement == null || !_webCameraReady) return;

    try {
      setState(() => _uploading = true);

      final blob = await captureFromVideo(_videoElement!);
      if (blob != null) {
        await _sendWebImage(blob);
      } else {
        throw Exception('Failed to create image blob');
      }
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Capture error: ${e.toString()}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendWebImage(dynamic imageBlob) async {
    if (!kIsWeb) return;

    List<double>? faceVector;
    try {
      final responseText = await sendBlobToServer(
        imageBlob,
        AppConstants.detectEndpoint,
      );

      final decoded = jsonDecode(responseText);
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Face not clear enough. Please try again."),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      await _processDetection(faceVector, conf);
    } catch (e) {
      debugPrint("Web upload error: $e");
      setState(() => _uploading = false);
      if (mounted) {
        _showServerErrorDialog();
      }
    }
  }

  Future<void> _processDetection(
    List<double> faceVector,
    double conf,
  ) async {
    final rollNo = StorageService.getString('roll_no');
    if (rollNo == null || rollNo.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Roll number not found. Please login again."),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    await CompareVector().putScannedVector(rollNo, jsonEncode(faceVector));
    final isMatch = await CompareVector().compareFaceVectors(rollNo);

    if (!isMatch) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Face doesn't match. Please try again."),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final sem = StorageService.getInt('semester');
    final subject = context.read<UserSession>().subject;
    final subject_id = context.read<UserSession>().subject_id;

    if (subject == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Subject not selected. Please go back and select a class.",
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (sem == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Semester not found. Please login again."),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    await MarkAttendance().markAttendance(rollNo, sem, subject, subject_id!);

    if (!mounted) return;
    _showSuccessScreen();
  }

  void _showSuccessScreen() {
    _controller?.dispose();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text(
              'Success',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Attendance marked successfully!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showServerErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text(
              'Server Down',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Face recognition server is currently under maintenance.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            SizedBox(height: 16),
            Text(
              'For assistance, contact:',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Text(
                  'hpu.ucbs@gmail.com',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
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
          if (kIsWeb)
            Positioned.fill(
              child: WebCameraWidget(onVideoReady: _onWebVideoReady),
            )
          else if (!kIsWeb && _controller != null)
            Positioned.fill(child: CameraPreview(_controller!)),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: InstructionCard(),
          ),
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
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.mediumImpact();

                  if (kIsWeb && _webCameraReady) {
                    await _captureWebImage();
                  } else if (_controller?.value.isInitialized == true) {
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
                "• AI captures 512-D facial vector\n\n"
                "🔒 Your photo will NOT be saved.\n"
                "We only extract a mathematical vector (512 numbers).",
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
