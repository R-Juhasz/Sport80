import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'screens/app_bootstrap_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseSafely();
  runApp(const ProviderScope(child: Sport80App()));
}

Future<void> _initializeFirebaseSafely() async {
  final shouldInitialize = kIsWeb || defaultTargetPlatform == TargetPlatform.android;
  if (!shouldInitialize) {
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
  }
}

class Sport80App extends StatelessWidget {
  const Sport80App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sport 80',
      theme: AppTheme.light(),
      routes: {
        '/': (context) => const AppBootstrapScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const HomeScreen(initialIndex: 2),
        '/progress': (context) => const HomeScreen(initialIndex: 1),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
