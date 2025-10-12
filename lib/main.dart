import 'package:flutter/material.dart';
import 'package:mood_check/screens/change_email.dart';
import 'package:mood_check/screens/change_password.dart';
import 'package:mood_check/screens/reset_screen.dart';
import 'package:mood_check/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_gate.dart';
import 'screens/confirmation_screen.dart';
import 'screens/new_password.dart';  // Import NewPasswordScreen

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://wlkhujlhdyojuxfesupv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indsa2h1amxoZHlvanV4ZmVzdXB2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNjg2NzYsImV4cCI6MjA3NTg0NDY3Nn0.VVT3_OZ-s3ncrCq0wKtXQPLOKQW7L3Zas_dofkKhcD8',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
onGenerateRoute: (RouteSettings settings) {
  final Uri uri = Uri.parse(settings.name ?? '');

  // Prioritize deep link handling
  if (uri.scheme == 'moodcheck') {
    if (uri.host == 'email-confirmation') {
      // Handle email confirmation link
      return MaterialPageRoute(
        builder: (_) => ConfirmationScreen(),
        settings: RouteSettings(arguments: uri),
      );
    } else if (uri.host == 'reset-password') {
      // Handle password reset link
      return MaterialPageRoute(
        builder: (_) => NewPasswordScreen(),
        settings: RouteSettings(arguments: uri),
      );
    }
  }

  // Return null for routes that aren't deep links
  return null; 
},
      home: const AuthGate(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/reset_password': (context) => const ResetScreen(),
        '/change_email': (context) => const ChangeEmail(),
        '/change_password': (context) => const ChangePassword(),
      },
    );
  }
}


class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({required this.page, this.direction = AxisDirection.left})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const beginOffset = {
              AxisDirection.left: Offset(1.0, 0.0),
              AxisDirection.right: Offset(-1.0, 0.0),
            };

            final offset = Tween<Offset>(
              begin: beginOffset[direction] ?? Offset.zero,
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: offset,
              child: child,
            );
          },
        );
}