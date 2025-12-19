import 'package:flutter/material.dart';

class UserSession extends ChangeNotifier {
  String? role;
  String? rollNo;
  String? name;
  String? sem;
  String? email;
  String? employeeid;
  void setrole(String value) {
    role = value;
    notifyListeners();
  }

  void setrollno(String value) {
    rollNo = value;
    notifyListeners();
  }

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setSem(String value) {
    sem = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setEmployeeId(String value) {
    employeeid = value;
    notifyListeners();
  }

  void clear() {
    role = null;
    rollNo = null;
    email = null;
    notifyListeners();
  }
}
