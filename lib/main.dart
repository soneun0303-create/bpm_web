import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'theme.dart';
import 'landing_page.dart';
import 'auth_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BpmApp());
}

class BpmApp extends StatelessWidget {
  const BpmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BPM Routine — 심박수로 완성하는 유산소 루틴',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
      },
    );
  }
}
