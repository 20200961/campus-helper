import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  void uploadPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('posts').add({
      'title': titleController.text,
      'content': contentController.text,
      'author': user.email ?? 'unknown',
      'timestamp': Timestamp.now(),
      'likes': 0,
      'comments': [],
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('글 작성')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: '내용'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: uploadPost, child: const Text('업로드')),
          ],
        ),
      ),
    );
  }
}
