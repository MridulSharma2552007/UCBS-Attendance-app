import 'dart:html' as html;
import 'dart:async';

Future<dynamic> captureFromVideo(dynamic videoElement) async {
  final canvas = html.CanvasElement(width: 640, height: 480);
  final ctx = canvas.context2D;
  ctx.drawImageScaled(videoElement, 0, 0, 640, 480);
  return await canvas.toBlob('image/jpeg', 0.8);
}

Future<String> sendBlobToServer(dynamic blob, String endpoint) async {
  final formData = html.FormData();
  formData.appendBlob('file', blob, 'capture.jpg');

  final request = html.HttpRequest();
  request.open('POST', endpoint);
  request.setRequestHeader('Accept', 'application/json');
  request.setRequestHeader('ngrok-skip-browser-warning', 'true');
  request.withCredentials = false;

  final completer = Completer<String>();
  request.onLoad.listen((e) {
    if (request.status == 200) {
      completer.complete(request.responseText!);
    } else {
      completer.completeError('Server error: ${request.status}');
    }
  });
  request.onError.listen((e) {
    completer.completeError('Network error');
  });

  request.send(formData);
  return await completer.future;
}