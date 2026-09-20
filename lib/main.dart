import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neet_paper_test/config/routes/app_router.dart';
import 'package:neet_paper_test/injection/injection_container.dart' as di;
// import 'firebase_options.dart'; // flutterfire configure chalane ke baad ise uncomment karein
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase Initialize karein
  try {
    // Agar aapne firebase setup kar liya hai toh niche wala code uncomment karein:
    /*
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    */
    print("Firebase Setup Ready (Configuration Pending)");
  } catch (e) {
    print("Firebase Error: $e");
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
