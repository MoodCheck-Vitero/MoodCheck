import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late TextEditingController _usernameController;
  late String _currentUsername;
  late String _currentEmail;
  late User? _user;

  @override
  void initState() {
    super.initState();

    _user = authService.value.currentUser;

    _currentUsername = _user?.userMetadata?['full_name'] ?? "";
    _currentEmail = _user?.email ?? "";

    _usernameController = TextEditingController(text: _currentUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      _showSnackBar(context, "Username cannot be empty");
      return;
    }

    try {
      await authService.value.updateUsername(username: newUsername);
      
      setState(() {
        _currentUsername = newUsername;
      });

      _showSnackBar(context, "Username updated successfully");
    } catch (e) {
      _showSnackBar(context, "Error saving changes: $e");
    }
  }

  Future<void> _logOut() async {
    await authService.value.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    _showSnackBar(context, "Logged out successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff009d03),
        centerTitle: true,
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(18), child: SizedBox()),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            _currentUsername.isNotEmpty ? "Signed in as $_currentUsername" : "Loading user...",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _logOut,
            child: const Text(
              "Log out",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 28),

          const Text("Username", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),

          const Text("Email Address", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(text: _currentEmail),
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),

          const Divider(),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined, color: Color(0xff009d03)),
            title: const Text("Change Email"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            onTap: () => Navigator.pushNamed(context, '/change_email'),
          ),
          const Divider(),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline, color: Color(0xff009d03)),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            onTap: () => Navigator.pushNamed(context, '/change_password'),
          ),
          const Divider(),

          const SizedBox(height: 200),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff009d03),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}