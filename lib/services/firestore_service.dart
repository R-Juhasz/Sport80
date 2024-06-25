import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update user data in Firestore
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));
    } catch (e) {
      print('Error adding/updating user: $e');
      throw Exception('Failed to add/update user data');
    }
  }
}
