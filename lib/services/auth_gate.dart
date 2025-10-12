import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/splash_screen.dart';
import '../screens/main_wrapper.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if the snapshot contains an authenticated user session
        if (snapshot.hasData && snapshot.data?.session != null) {
          // If the user is authenticated, return the MainWrapper
          return const MainWrapper();
        }

        // If the user is not authenticated, just return the SplashScreen
        return const SplashScreen();
      },
    );
  }
}
