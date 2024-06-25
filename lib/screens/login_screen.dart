// Essential imports for UI components, Riverpod for state management, authentication, and Firestore services
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport80/providers/auth_provider.dart';
import 'package:sport80/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// LoginScreen is a ConsumerWidget, which uses Riverpod to listen to state changes in the app
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key,});  // Constructor with key initialization

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controllers for text fields
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          // Background image for the login screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/track image 1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay to improve text visibility over the background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.4), Colors.black],
                ),
              ),
            ),
          ),
          // Center-aligned form for login input fields
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Email input field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Password input field
                  TextField(
                    controller: passwordController,
                    obscureText: true,  // Obscures text for password secrecy
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Button for signing in
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text('Sign in', style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      try {
                        // Attempt to sign in with provided credentials
                        await ref.read(authProvider).signInWithEmailAndPassword(
                            emailController.text, passwordController.text);
                        // On success, navigate to the home screen
                        Navigator.of(context).pushReplacementNamed('/home');
                      } catch (e) {
                        // Display an error message if sign in fails
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to sign in: ${e.toString()}')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Link to reset password
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/forgot_password'),
                    child: const Text('Forgot Password?', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  // Separator text
                  const Center(
                    child: Text("--- OR ---", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  // Link to registration page
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/register'),
                    child: const Text('Need an account? Register', style: TextStyle(color: Colors.white)),
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


final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// RegistrationScreen is also a ConsumerWidget for registering new users
class RegistrationScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Adapt form width based on screen size
    double formWidth = MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.85;

    // Read Firestore service from provider
    final firestoreService = ref.read(firestoreServiceProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: formWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username input field
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 20),
                // Email input field
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 20),
                // Password input field
                TextFormField(
                  controller: passwordController,
                  obscureText: true, // Obscures text for password secrecy
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                // Button to create an account
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Register user with provided credentials
                      UserCredential userCredential = await ref.read(authProvider).registerWithEmailAndPassword(
                        emailController.text, passwordController.text,
                      );

                      // Add user details to Firestore
                      await firestoreService.addUser(userCredential.user!.uid, {
                        'username': usernameController.text,
                        'email': emailController.text,
                      });

                      // On success, navigate to the home screen
                      Navigator.of(context).pushReplacementNamed('/home');
                    } catch (e) {
                      // Display an error message if registration fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to register: $e')),
                      );
                    }
                  },
                  child: const Text('Create Account'),
                ),
                const SizedBox(height: 20),
                // Button to cancel registration and return to the previous screen
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
