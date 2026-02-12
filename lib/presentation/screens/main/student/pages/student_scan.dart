import 'dart:convert';
import 'dart:io';
import 'dart:html' as html show File;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

class StudentScan extends StatefulWidget {
  const StudentScan({super.key});

  @override
  State<StudentScan> createState() => _StudentScanState();
}

class _StudentScanState extends State<StudentScan>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription>? _cameras;
  String _displayedText = '';
  final String _fullText =
      "🔒 We're not storing your photo. Only extracting 512D face vectors. No one can see your photo, not even us.";

  XFile? _image;
  bool _uploading = false;
  bool _showSuccess = false;

  Future<bool> getCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
    _startTypingAnimation();
  }

  void _startTypingAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i <= _fullText.length; i++) {
      if (mounted) {
        setState(() {
          _displayedText = _fullText.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 30));
      }
    }
  }

  Future<void> _initCamera() async {
    final allowed = await getCameraPermission();
    if (!allowed) return;

    _cameras = await availableCameras();

    final camera = _cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();

    setState(() {});
  }

  Future<void> _sendImage(String path) async {
    List<double>? faceVector;
    try {
      setState(() {
        _uploading = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConstants.detectEndpoint),
      );

      if (kIsWeb) {
        final bytes = await _image!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('file', bytes,
            filename: 'capture.jpg'));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', path));
      }

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - server may be down');
        },
      );
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
        setState(() {
          _image = null;
        });
        return;
      }

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
        setState(() {
          _image = null;
        });
        return;
      }

      await CompareVector().putScannedVector(rollNo, jsonEncode(faceVector));

      // Compare vectors
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
        setState(() {
          _image = null;
        });
        return;
      }
      if (isMatch) {
        MarkAttendance markAttendance = MarkAttendance();
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

        await markAttendance.markAttendance(rollNo, sem, subject, subject_id!);
      }

      if (mounted) {
        _showSuccessScreen();
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (mounted) {
        setState(() {
          _uploading = false;
          _image = null;
        });
        _showServerErrorDialog();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _showSuccessScreen() {
    _controller?.dispose();

    setState(() {
      _showSuccess = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller == null
          ? const Center(
              child: Text(
                "Camera not available",
                style: TextStyle(color: Colors.white),
              ),
            )
          : FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_showSuccess) {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.withOpacity(0.2),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 80,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              '✅ Attendance Marked!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'You\'re all set for today',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Redirecting...',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_image != null) {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: StudentTheme.accentcoral,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Processing your face...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Extracting 512D vectors',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.previewSize?.width ?? 1,
                            height: _controller!.value.previewSize?.height ?? 1,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.0, 0.2, 0.8, 1.0],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: StudentTheme.accentcoral.withOpacity(0.5),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 80,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            Text(
                              '👤 Face Recognition',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Position your face in the circle',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 180,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _displayedText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                try {
                                  await _initializeControllerFuture;
                                  final image = await _controller!
                                      .takePicture();
                                  setState(() {
                                    _image = image;
                                  });
                                  await _sendImage(image.path);
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: StudentTheme.accentcoral
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: StudentTheme.accentcoral,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to capture',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
    );
  }
}
