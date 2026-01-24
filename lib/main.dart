import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucbs_attendance_app/core/config/app_config.dart';
import 'package:ucbs_attendance_app/core/services/storage_service.dart';

import 'package:ucbs_attendance_app/firebase_options.dart';
import 'package:ucbs_attendance_app/presentation/providers/Data/user_session.dart';
import 'package:ucbs_attendance_app/presentation/screens/login/Gates/app_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize storage service first
  await StorageService.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserSession())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppGate(),
    );
  }
}
