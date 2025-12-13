import 'package:flutter/material.dart';

class UserSession extends ChangeNotifier {
  String? role;
  String? rollNo;
  String? name;
  String? sem;
  void setrole(String value) {
    role = value;
    notifyListeners();
  }

  void setrollno(String value) {
    role = value;
    notifyListeners();
  }

  void setName(String value) {
    name = value;
  }

  void clear() {
    role = null;
    rollNo = null;
    notifyListeners();
  }
}
