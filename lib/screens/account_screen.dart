import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late TextEditingController _usernameController;
  String? _email;

  @override
  void initState() {
    super.initState();

    // Placeholder/mock values
    _usernameController = TextEditingController(text: "John Doe");
    _email = "john.doe@example.com";
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      _showSnackBar(context, "Username cannot be empty");
      return;
    }

    // Mock success feedback
    _showSnackBar(context, "Username updated (mock)");
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
            "Signed in as John Doe", // Mock display name
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              _showSnackBar(context, "Logged out (mock)");
            },
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
            controller: TextEditingController(text: _email ?? ""),
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),

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
        backgroundColor: const Color(0xFF001F8D),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}