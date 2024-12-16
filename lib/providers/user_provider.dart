// Import necessary packages for Firebase Auth, Firestore database, and state management using Riverpod
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport80/models/app_user.dart';  // Import the user model

// Define a provider for FirebaseAuth instance, used for authentication tasks
final authServiceProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Define a provider for user state management, creating an instance of UserProvider
final userProvider = StateNotifierProvider<UserProvider, AppUser?>((ref) {
  return UserProvider(ref as ProviderRef);  // Cast ref to ProviderRef and pass to UserProvider
});

// Define UserProvider class extending StateNotifier for managing AppUser state
class UserProvider extends StateNotifier<AppUser?> {
  final ProviderRef ref;  // Reference to use other providers

  // Constructor initializing the state to null and invoking _loadUser to fetch user data
  UserProvider(this.ref) : super(null) {
    _loadUser();  // Load user data on initialization
  }

  // Private method to load current user data from Firestore
  void _loadUser() async {
    var user = ref.read(authServiceProvider).currentUser;  // Read current user from FirebaseAuth
    if (user != null) {
      var userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();  // Fetch user data from Firestore
      if (userData.exists) {
        state = AppUser.fromMap(userData.data()!);  // Set state to user data if exists
      }
    }
  }

  // Public method to update user data in Firestore and locally
  void updateUser(AppUser updatedUser) async {
    state = updatedUser;  // Update local state first
    try {
      await FirebaseFirestore.instance.collection('users').doc(updatedUser.id).update(updatedUser.toMap());  // Push updates to Firestore
    } catch (e) {
      print('Failed to update user in Firestore: $e');  // Handle errors in updating user
    }
  }

  // Method to add new user data to Firestore
  Future<void> addUserToFirestore(String username, String email) async {
    try {
      var user = ref.read(authServiceProvider).currentUser;  // Get current authenticated user
      if (user != null) {
        var userData = AppUser(id: user.uid, email: email, username: username);  // Create new AppUser instance
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData.toMap());  // Add user data to Firestore
      }
    } catch (e) {
      print('Failed to add user to Firestore: $e');  // Handle errors in adding user
    }
  }
}
