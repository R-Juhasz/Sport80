// Import necessary packages for Firebase Auth, Firestore database, and state management using Riverpod
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport80/models/app_user.dart'; // Import the AppUser data model
import 'package:sport80/services/auth_service.dart'; // Import the AuthService for additional authentication functionality

// Define a provider for FirebaseAuth instance, used for authentication tasks
final authServiceProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Define a provider that creates an AuthService instance for managing authentication-related operations
final authProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Define UserProvider class extending StateNotifier for managing AppUser state
class UserProvider extends StateNotifier<AppUser?> {
  final ProviderRef ref; // Reference to interact with other providers

  // Constructor initializing the state to null
  UserProvider(this.ref) : super(null);

  // Asynchronous method to initialize user data from Firestore
  Future<void> initUser() async {
    var user = ref.read(authServiceProvider).currentUser; // Get the current user from FirebaseAuth
    if (user != null) {
      try {
        var userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get(); // Attempt to fetch user data from Firestore
        if (userData.exists) {
          // If user data is found, update the display name and update the state
          await _updateDisplayName(user); // Update the user's display name if necessary
          state = AppUser.fromMap(userData.data()!); // Set state to the fetched user data
        } else {
          print('User data does not exist in Firestore');
        }
      } catch (e) {
        print('Failed to load user: $e'); // Log failure to load user data
      }
    }
  }

  // Asynchronous private method to update the user's display name if it's not set
  Future<void> _updateDisplayName(User user) async {
    if (user.displayName == null) {
      // If the user's display name is not set
      final displayName = await ref.read(authProvider).getUserDisplayName(user.uid); // Get display name from AuthService
      if (displayName != null) {
        try {
          await user.updateDisplayName(displayName); // Update the user's display name in FirebaseAuth
        } catch (e) {
          print('Failed to update display name: $e'); // Log failure to update display name
        }
      }
    }
  }

  // Asynchronous method to update user data in Firestore and update local state
  Future<void> updateUser(AppUser updatedUser) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(updatedUser.id).update(updatedUser.toMap()); // Update user data in Firestore
      state = updatedUser; // Update local state only on successful Firestore update
    } catch (e) {
      print('Failed to update user in Firestore: $e'); // Log failure to update user data in Firestore
      throw Exception('Update failed'); // Throw an exception to indicate failure, which could be handled by the UI
    }
  }
}
