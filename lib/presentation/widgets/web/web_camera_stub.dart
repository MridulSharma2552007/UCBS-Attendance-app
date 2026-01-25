import 'package:flutter/material.dart';

class WebCameraWidget extends StatelessWidget {
  final Function(dynamic) onVideoReady;
  
  const WebCameraWidget({super.key, required this.onVideoReady});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}