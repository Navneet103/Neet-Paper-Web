import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neet_paper_test/config/routes/app_router.dart';
import 'package:neet_paper_test/injection/injection_container.dart' as di;
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase Initialize karein
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase Connected Successfully to neet-paper-test");
  } catch (e) {
    debugPrint("Firebase Error: $e");
  }

  // 2. Initialize Dependency Injection (Drift Database init yahan hoga)
  await di.init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NEET Exam Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
