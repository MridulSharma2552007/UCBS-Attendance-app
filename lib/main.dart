import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/apis/apikeys.dart';
import 'package:ucbs_attendance_app/firebase_options.dart';
import 'package:ucbs_attendance_app/provider/user_session.dart';
import 'package:ucbs_attendance_app/views/login/login.dart';
import 'package:ucbs_attendance_app/views/main/student/home.dart';
import 'package:ucbs_attendance_app/views/main/teacher/teacher_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(url: Apikeys.url, anonKey: Apikeys.anonKey);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserSession())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<UserSession>(
        builder: (context, session, _) {
          if (!session.isLogged) {
            return const Login();
          }

          if (session.role == "Student" && session.rollNo != null) {
            return const Home();
          }

          if (session.role == "Teacher" && session.employeeid != null) {
            return const TeacherHome();
          }

          return const Login();
        },
      ),
    );
  }
}
