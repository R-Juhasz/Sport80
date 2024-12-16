import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport80/providers/auth_provider.dart';

import '../providers/firestore_provider.dart';

// Shared gradient for both screens
const kBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(gradient: kBackgroundGradient),
          ),
          // Centered login form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo with blending and styling
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [Colors.white70, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/track image 1.jpg',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),


                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(emailController, "Email"),
                          const SizedBox(height: 16),
                          _buildTextField(passwordController, "Password", obscureText: true),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await ref.read(authProvider).signInWithEmailAndPassword(
                                    emailController.text, passwordController.text);
                                Navigator.of(context).pushReplacementNamed('/home');
                              } catch (e) {
                                _showErrorSnackbar(context, 'Failed to sign in: $e');
                              }
                            },
                            icon: const Icon(Icons.login),
                            label: const Text("Sign In"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/forgot_password'),
                            child: const Text("Forgot Password?"),
                          ),
                          const Divider(),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/register'),
                            child: const Text("Don't have an account? Register"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegistrationScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(gradient: kBackgroundGradient),
          ),
          // Centered registration form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo with blending and styling
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [Colors.white70, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/track image 1.jpg',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),


                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(usernameController, "Username"),
                          const SizedBox(height: 16),
                          _buildTextField(emailController, "Email"),
                          const SizedBox(height: 16),
                          _buildTextField(passwordController, "Password", obscureText: true),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                final userCredential = await ref
                                    .read(authProvider)
                                    .registerWithEmailAndPassword(
                                  emailController.text,
                                  passwordController.text,
                                );

                                await firestoreService.addUser(userCredential.user!.uid, {
                                  'username': usernameController.text,
                                  'email': emailController.text,
                                });

                                Navigator.of(context).pushReplacementNamed('/home');
                              } catch (e) {
                                _showErrorSnackbar(context, 'Failed to register: $e');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Create Account"),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper method for text fields
Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}

// Helper method for showing error messages
void _showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ),
  );
}

