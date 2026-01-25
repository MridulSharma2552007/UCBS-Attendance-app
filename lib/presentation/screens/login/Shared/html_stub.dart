// Stub implementations for mobile platforms
class CanvasElement {
  CanvasElement({int? width, int? height});
  dynamic get context2D => _CanvasContext();
  Future<Blob?> toBlob(String type, double quality) async => Blob();
}

class _CanvasContext {
  void drawImageScaled(dynamic image, int x, int y, int w, int h) {}
}

class FormData {
  void appendBlob(String name, dynamic blob, String filename) {}
}

class HttpRequest {
  void open(String method, String url) {}
  void setRequestHeader(String header, String value) {}
  set withCredentials(bool value) {}
  void send(dynamic data) {}
  Stream get onLoad => Stream.empty();
  Stream get onError => Stream.empty();
  int? get status => null;
  String? get responseText => null;
}

class Blob {}
