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
import 'package:ucbs_attendance_app/data/services/supabase/Student/verified_student.dart';
import 'package:ucbs_attendance_app/data/services/supabase/Teacher/verify_teacher.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/home.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/teacher/pages/subject_selection.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

// Web-specific imports
import 'dart:html' as html;
import 'dart:typed_data' show Uint8List;

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _loading = true;
  bool _uploading = false;
  html.VideoElement? _videoElement;
  html.MediaStream? _stream;

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
    try {
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      _stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {'facingMode': 'user'}
      });

      _videoElement!.srcObject = _stream;
      
      // Register the video element
      html.document.body!.append(_videoElement!);
      
      setState(() => _loading = false);
    } catch (e) {
      debugPrint('Web camera error: $e');
      setState(() => _loading = false);
    }
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
    final userdata = context.read<UserSession>();
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

      await _processDetection(userdata, faceVector, conf);
    } catch (e) {
      debugPrint("Upload error: $e");
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _captureWebImage() async {
    if (_videoElement == null) return;
    
    try {
      final canvas = html.CanvasElement(width: 640, height: 480);
      final ctx = canvas.context2D;
      
      ctx.drawImageScaled(_videoElement!, 0, 0, 640, 480);
      
      final blob = await canvas.toBlob('image/jpeg', 0.8);
      await _sendWebImage(blob);
    } catch (e) {
      debugPrint('Web capture error: $e');
    }
  }

  Future<void> _sendWebImage(html.Blob imageBlob) async {
    final userdata = context.read<UserSession>();
    List<double>? faceVector;
    try {
      setState(() => _uploading = true);

      final formData = html.FormData();
      formData.appendBlob('file', imageBlob, 'capture.jpg');

      final request = html.HttpRequest();
      request.open('POST', AppConstants.detectEndpoint);
      
      final completer = Completer<String>();
      request.onLoad.listen((e) {
        completer.complete(request.responseText!);
      });
      request.onError.listen((e) {
        completer.completeError('Request failed');
      });
      
      request.send(formData);
      final responseText = await completer.future;
      
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

      await _processDetection(userdata, faceVector, conf);
    } catch (e) {
      debugPrint("Web upload error: $e");
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processDetection(userdata, List<double> faceVector, double conf) async {
    final int? employeeId = StorageService.getInt(AppConstants.employeeIdKey);

    if (userdata.role == AppConstants.teacherRole) {
      if (employeeId == null) {
        throw Exception("Employee ID not found in storage");
      }
      await VerifyTeacher().pushTeacherData(
        id: employeeId,
        email: userdata.email!,
        name: userdata.name!,
        vector: faceVector,
        confidence: conf,
      );
    } else if (userdata.role == AppConstants.studentRole) {
      await VerifiedStudent().pushStudentData(
        email: userdata.email!,
        name: userdata.name!,
        rollNo: userdata.rollNo!,
        sem: userdata.sem!,
        vector: faceVector,
        confidence: conf,
      );
    }

    if (!mounted) return;

    await StorageService.setString(AppConstants.roleKey, userdata.role!);
    await StorageService.setBool(AppConstants.isLoggedKey, true);

    await Future.delayed(const Duration(seconds: 1));
    _controller?.dispose();
    _stream?.getTracks().forEach((track) => track.stop());

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => userdata.role == AppConstants.teacherRole 
            ? const SubjectSelection() 
            : const Home(),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _stream?.getTracks().forEach((track) => track.stop());
    _videoElement?.remove();
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
          if (kIsWeb && _videoElement != null)
            Positioned.fill(
              child: HtmlElementView(viewType: 'video-${_videoElement.hashCode}'),
            )
          else if (!kIsWeb && _controller != null)
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

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.mediumImpact();

                  if (kIsWeb) {
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
