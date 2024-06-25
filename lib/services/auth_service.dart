// Import Firebase authentication package for user authentication tasks
import 'package:firebase_auth/firebase_auth.dart';
// Import Firebase Firestore package for database interactions
import 'package:cloud_firestore/cloud_firestore.dart';

// Define a class called AuthService for handling authentication and user data fetching
class AuthService {
  // Private FirebaseAuth instance for handling all authentication tasks
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Private FirebaseFirestore instance for interacting with Firestore database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to sign in a user with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Attempt to sign in the user with provided email and password
      return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // If sign in fails, throw an exception with an error message
      throw Exception('Failed to sign in with email and password: ${e.toString()}');
    }
  }

  // Method to register a new user with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      // Attempt to create a new user with provided email and password
      return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // If registration fails, throw an exception with an error message
      throw Exception('Failed to register with email and password: ${e.toString()}');
    }
  }

  // Method to sign out the currently signed-in user
  Future<void> signOut() async {
    try {
      // Attempt to sign out the current user
      await _firebaseAuth.signOut();
    } catch (e) {
      // If sign out fails, throw an exception with an error message
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Getter to retrieve the currently authenticated user
  User? get currentUser {
    // Returns the current user if logged in, null otherwise
    return _firebaseAuth.currentUser;
  }

  // Method to fetch the display name of a user from Firestore by their user ID
  Future<String?> getUserDisplayName(String uid) async {
    try {
      // Attempt to retrieve the user document from Firestore using the user ID
      var userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        // If the document exists, extract and return the display name
        return userDoc['displayName'] as String?;
      } else {
        // If the document does not exist, log a message indicating absence and return null
        print('User document not found in Firestore');
        return null;
      }
    } catch (e) {
      // If there is an error during the fetch, log the error and return null
      print('Error fetching user display name: $e');
      return null;
    }
  }
}

