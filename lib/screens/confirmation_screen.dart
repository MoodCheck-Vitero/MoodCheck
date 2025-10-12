import 'package:flutter/material.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  Uri? confirmationUri; // To hold the deep link
  bool isLoading = true;
  bool isConfirmed = false;
  String errorMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieving the deep link from route arguments
    final Uri? uri = ModalRoute.of(context)?.settings.arguments as Uri?;

    // If the uri is not null, assign it to the confirmationUri variable
    if (uri != null) {
      confirmationUri = uri;
    }

    // Extract the token from the deep link
    final token = confirmationUri?.queryParameters['token'];

    if (token != null && token.isNotEmpty) {
      _verifyEmail(token);
    } else {
      setState(() {
        isLoading = false;
        errorMessage = "Invalid confirmation link.";
      });
    }
  }

  // Function to verify the email using the token
  Future<void> _verifyEmail(String token) async {
    try {
      // Simulating email verification with a dummy API call or service.
      // Replace this with your actual API or Supabase call to verify the token.
      await Future.delayed(const Duration(seconds: 2)); // Simulating network delay
      
      // Simulate successful confirmation (you can replace this logic with actual verification)
      setState(() {
        isLoading = false;
        isConfirmed = true;  // Simulate the email being confirmed.
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 40),
              const Text(
                "Email Confirmation",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              isLoading
                  ? const CircularProgressIndicator()
                  : isConfirmed
                      ? const Text(
                          "Your email has been successfully confirmed.",
                          style: TextStyle(
                              color: Color.fromARGB(255, 107, 107, 107),
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          errorMessage.isNotEmpty ? errorMessage : "Unknown error",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 0, 0),
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff009d03),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  onPressed: () {
                    if (isConfirmed) {
                      // Navigate to login after successful confirmation
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    } else {
                      // Show error if the token is invalid
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errorMessage.isNotEmpty ? errorMessage : 'Failed to confirm email.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Continue to Login",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}