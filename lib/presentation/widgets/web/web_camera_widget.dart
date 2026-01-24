import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

class WebCameraWidget extends StatefulWidget {
  final Function(html.VideoElement) onVideoReady;
  
  const WebCameraWidget({super.key, required this.onVideoReady});

  @override
  State<WebCameraWidget> createState() => _WebCameraWidgetState();
}

class _WebCameraWidgetState extends State<WebCameraWidget> {
  late String viewId;
  html.VideoElement? videoElement;

  @override
  void initState() {
    super.initState();
    viewId = 'video-${DateTime.now().millisecondsSinceEpoch}';
    _registerVideoElement();
  }

  void _registerVideoElement() {
    videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) => videoElement!,
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {'facingMode': 'user'}
      });
      
      videoElement!.srcObject = stream;
      
      videoElement!.onLoadedMetadata.listen((_) {
        widget.onVideoReady(videoElement!);
      });
      
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewId);
  }
}