import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _loading = false;

  String? _newPasswordError;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xff009d03),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _validateNewPassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
    });
  }

  Future<void> handleChangePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    setState(() {
      _newPasswordError = null;
    });
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showSnackBar("Please fill out all fields.");
      return;
    }
    if (newPassword.length < 8) {
      _showSnackBar("Password must be at least 8 characters.");
      return;
    }
    if (!newPassword.contains(RegExp(r'[A-Z]'))) {
      _showSnackBar("Password must contain at least 1 uppercase letter.");
      return;
    }
    if (!newPassword.contains(RegExp(r'[a-z]'))) {
      _showSnackBar("Password must contain at least 1 lowercase letter.");
      return;
    }
    if (!newPassword.contains(RegExp(r'[0-9]'))) {
      _showSnackBar("Password must contain at least 1 number.");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = authService.value.currentUser;
      if (user == null || user.email == null) {
        throw Exception("No logged in user.");
      }

      final signInResponse = await authService.value.signIn(
        email: user.email!,
        password: currentPassword,
      );

      if (signInResponse.user == null) {
        _showSnackBar("The current password is incorrect. Please try again.");
        setState(() => _loading = false);
        return;
      }

      await authService.value.updateCurrentPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await authService.value.signOut();

      _showSnackBar("Your password has been updated. Please log in again.", isError: false);

      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      _showSnackBar("The current password is incorrect. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    newPasswordController.addListener(() {
      _validateNewPassword(newPasswordController.text);
    });
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xff009d03),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Current Password", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: currentPasswordController,
              obscureText: _obscureCurrentPassword,
              decoration: InputDecoration(
                hintText: "Enter current password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("New Password", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                hintText: "Enter new password",
                border: const OutlineInputBorder(),
                errorText: _newPasswordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _hasMinLength ? Icons.check_circle : Icons.error,
                      color: _hasMinLength ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    const Text("At least 8 characters"),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _hasUppercase ? Icons.check_circle : Icons.error,
                      color: _hasUppercase ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    const Text("At least 1 uppercase letter"),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _hasLowercase ? Icons.check_circle : Icons.error,
                      color: _hasLowercase ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    const Text("At least 1 lowercase letter"),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _hasNumber ? Icons.check_circle : Icons.error,
                      color: _hasNumber ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    const Text("At least 1 number"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff009d03),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _loading ? null : handleChangePassword,
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        "Update Password",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
