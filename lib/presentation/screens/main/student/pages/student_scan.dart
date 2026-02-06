import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';

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
  AnimationController? _typingController;
  String _displayedText = '';
  final String _fullText =
      "🔒 We're not storing your photo. Only extracting 512D face vectors. No one can see your photo, not even us.";

  XFile? _image;

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

  @override
  void dispose() {
    _controller?.dispose();
    _typingController?.dispose();
    super.dispose();
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

                  final size = MediaQuery.of(context).size;
                  final scale =
                      1 / (_controller!.value.aspectRatio * size.aspectRatio);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.scale(
                        scale: scale,
                        child: Center(child: CameraPreview(_controller!)),
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
