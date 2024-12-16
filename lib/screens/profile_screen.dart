import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _newPasswordController;
  String? _userId;
  ImageProvider? _profileImageProvider;
  bool _isLoading = true;
  bool _isUpdatingProfile = false;
  bool _isChangingPassword = false;

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
      try {
        final userData =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();
        if (userData.exists) {
          final data = userData.data();
          setState(() {
            _usernameController.text = data?['username'] ?? '';
            _emailController.text = data?['email'] ?? '';
            _profileImageProvider = (data?['profileImageUrl'] != null
                ? NetworkImage(data?['profileImageUrl'])
                : const AssetImage('assets/images/sport80.png')) as ImageProvider<Object>?;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final Reference storageRef =
        FirebaseStorage.instance.ref().child('profile_images/$_userId.jpg');
        final UploadTask uploadTask = storageRef.putFile(File(image.path));

        await uploadTask.whenComplete(() async {
          final String downloadUrl = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance.collection('users').doc(_userId).update({
            'profileImageUrl': downloadUrl,
          });
          setState(() {
            _profileImageProvider = NetworkImage(downloadUrl);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully!')),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and email cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'username': _usernameController.text,
        'email': _emailController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() {
        _isUpdatingProfile = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(_newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password: $e')),
      );
    } finally {
      setState(() {
        _isChangingPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageProvider,
                ),
                IconButton(
                  onPressed: _updateProfileImage,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(controller: _usernameController, labelText: 'Username'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _emailController, labelText: 'Email'),
                    const SizedBox(height: 24),
                    _buildActionButton(
                      onPressed: _isUpdatingProfile ? null : _updateProfile,
                      isLoading: _isUpdatingProfile,
                      label: 'Update Profile',
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(
                        controller: _newPasswordController,
                        labelText: 'New Password',
                        obscureText: true),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      onPressed: _isChangingPassword ? null : _changePassword,
                      isLoading: _isChangingPassword,
                      label: 'Change Password',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String label,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white, // Ensure text is always visible
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
