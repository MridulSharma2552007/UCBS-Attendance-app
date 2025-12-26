import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/apis/apikey.dart';
import 'package:ucbs_attendance_app/firebase_options.dart';
import 'package:ucbs_attendance_app/provider/Data/user_session.dart';
import 'package:ucbs_attendance_app/views/login/Gates/app_gate.dart';

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
    return MaterialApp(debugShowCheckedModeBanner: false, home: AppGate());
  }
}
