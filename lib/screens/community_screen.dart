import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _postController = TextEditingController();
  File? _selectedImage;
  bool _isPosting = false;

  Future<void> _createPost() async {
    if (_postController.text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('community_posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await _firestore.collection('posts').add({
        'text': _postController.text,
        'image': imageUrl,
        'timestamp': Timestamp.now(),
        'likes': 0,
        'comments': [],
      });

      _postController.clear();
      _selectedImage = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Widget _buildPostCard(Map<String, dynamic> postData, String postId) {
    final text = postData['text'] ?? '';
    final image = postData['image'];
    final timestamp = (postData['timestamp'] as Timestamp).toDate();
    final likes = postData['likes'] ?? 0;
    final comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Content
            if (text.isNotEmpty)
              Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            if (image != null)
              const SizedBox(height: 10),
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(image, fit: BoxFit.cover),
              ),
            const SizedBox(height: 8),

            // Timestamp and Likes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
                      onPressed: () async {
                        await _firestore
                            .collection('posts')
                            .doc(postId)
                            .update({'likes': likes + 1});
                      },
                    ),
                    Text('$likes'),
                  ],
                ),
              ],
            ),

            // Comments Section
            const Divider(),
            if (comments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comments.map((comment) {
                  final commentText = comment['text'] ?? '';
                  final commentTimestamp =
                  (comment['timestamp'] as Timestamp).toDate();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '$commentText - ${commentTimestamp.day}/${commentTimestamp.month}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                }).toList(),
              ),
            TextField(
              decoration: const InputDecoration(hintText: 'Add a comment...'),
              onSubmitted: (commentText) async {
                if (commentText.isNotEmpty) {
                  await _firestore.collection('posts').doc(postId).update({
                    'comments': FieldValue.arrayUnion([
                      {
                        'text': commentText,
                        'timestamp': Timestamp.now(),
                      }
                    ])
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: Column(
        children: [
          // Post Creation Section
          Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _postController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _selectImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Add Image'),
                      ),
                      ElevatedButton(
                        onPressed: _isPosting ? null : _createPost,
                        child: _isPosting
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                            : const Text('Post'),
                      ),
                    ],
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImage!, height: 100, fit: BoxFit.cover),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Feed Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No posts yet. Be the first to post!'));
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final postData = posts[index].data() as Map<String, dynamic>;
                    final postId = posts[index].id;
                    return _buildPostCard(postData, postId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
