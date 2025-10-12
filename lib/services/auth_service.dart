import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<AuthResponse> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
      emailRedirectTo: 'myapp://email-confirmed?email=$email',
    );
    return response;
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> updateUsername({required String username}) async {
    await supabase.auth.updateUser(UserAttributes(data: {'full_name': username}));
  }

  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    // Supabase doesn’t require re-auth for updating email, but it’s good to verify first.
    await supabase.auth.updateUser(UserAttributes(email: newEmail));
  }

  Future<void> resetCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    // Supabase doesn't allow re-auth like Firebase. You directly update the password.
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}