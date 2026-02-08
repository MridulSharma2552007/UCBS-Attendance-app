import 'package:flutter/material.dart';

class UserSession extends ChangeNotifier {
  String? role;
  String? rollNo;
  String? name;
  String? sem;
  String? email;
  int? employeeid;
  String? subject;
  int? subject_id;

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

  void setEmployeeId(int value) {
    employeeid = value;
    notifyListeners();
  }

  void selectedClass(String value, int id) {
    subject = value;
    subject_id = id;
    print('*********selected class********: $subject, ID: $subject_id');
    notifyListeners();
  }

  void clear() {
    role = null;
    rollNo = null;
    email = null;
    notifyListeners();
  }
}
