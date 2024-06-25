import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _newPasswordController;
  String? _userId;
  ImageProvider? _profileImageProvider = const AssetImage('assets/images/sport80 logo.png');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _newPasswordController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid;
    if (_userId != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (userData.exists) {
        final data = userData.data();
        setState(() {
          _usernameController.text = data?['username'] ?? '';
          _emailController.text = data?['email'] ?? '';
          _profileImageProvider = data?['profileImageUrl'] != null ? NetworkImage(data?['profileImageUrl']) : _profileImageProvider;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload the image to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$_userId.jpg');
      final UploadTask uploadTask = storageRef.putFile(File(image.path));

      // Listen for completion or errors
      await uploadTask.whenComplete(() async {
        if (uploadTask.snapshot.state == TaskState.success) {
          final String downloadUrl = await storageRef.getDownloadURL();
          // Update the user's profileImageUrl in Firestore
          await FirebaseFirestore.instance.collection('users').doc(_userId).update({
            'profileImageUrl': downloadUrl,
          });
          setState(() {
            _profileImageProvider = NetworkImage(downloadUrl);
          });
        } else {
          // Handle upload error
          print('Error uploading image');
        }
      });
    }
  }


  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _newPasswordController.text.isNotEmpty) {
      try {
        await user.updatePassword(_newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to change password: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _updateProfileImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImageProvider,
                child: _profileImageProvider == const AssetImage('assets/placeholder.png') ? const Icon(Icons.person, size: 60) : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('users').doc(_userId).update({
                  'username': _usernameController.text,
                  'email': _emailController.text,
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Profile updated successfully'),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Update Profile'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
