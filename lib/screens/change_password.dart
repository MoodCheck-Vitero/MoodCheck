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
    if (value.length < 8) {
      setState(() {
        _newPasswordError = "Password must be at least 8 characters.";
      });
    } else {
      setState(() {
        _newPasswordError = null;
      });
    }
  }

  Future<void> handleChangePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    // Clear any previous error state for new password
    setState(() {
      _newPasswordError = null;
    });

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showSnackBar("Please fill out all fields.");
      return;
    }

    if (newPassword.length < 8) {
      setState(() {
        _newPasswordError = "Password must be at least 8 characters.";
      });
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

      // Log out user after successful password change
      await authService.value.signOut();

      _showSnackBar("Your password has been updated. Please log in again.", isError: false);

      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        Navigator.pop(context); // Or navigate to login screen explicitly if needed
      }
    } catch (e) {
      _showSnackBar("The current password is incorrect. Please Try Again");
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
        backgroundColor: const Color(0xff009d03),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(18),
          child: SizedBox(),
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