import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectSelection extends StatefulWidget {
  const SubjectSelection({super.key});

  @override
  State<SubjectSelection> createState() => _SubjectSelectionState();
}

class _SubjectSelectionState extends State<SubjectSelection> {
  void setlogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLogged", true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
