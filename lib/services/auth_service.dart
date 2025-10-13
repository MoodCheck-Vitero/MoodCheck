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
  }) async {
    await supabase.auth.updateUser(UserAttributes(email: newEmail));
  }

  Future<void> updateCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}