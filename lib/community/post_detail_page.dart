import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final commentController = TextEditingController();
  final auth = FirebaseAuth.instance;

  Future<void> likePost(DocumentSnapshot postDoc) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({'likes': (postDoc['likes'] ?? 0) + 1});
  }

  Future<void> addComment() async {
    final comment = commentController.text.trim();
    if (comment.isEmpty) return;

    final user = auth.currentUser;
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({
          'comments': FieldValue.arrayUnion([
            '${user?.email ?? "익명"}: $comment',
          ]),
        });

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 상세')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final post = snapshot.data!;
          final postData = post.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postData['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(postData['content'] ?? ''),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      onPressed: () => likePost(post),
                    ),
                    Text('❤ ${postData['likes'] ?? 0}'),
                  ],
                ),
                const Divider(),
                const Text('댓글', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children:
                        (postData['comments'] as List<dynamic>? ?? [])
                            .map((c) => Text('- $c'))
                            .toList(),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(hintText: '댓글 입력'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: addComment,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
