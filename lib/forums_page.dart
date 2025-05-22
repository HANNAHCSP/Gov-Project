import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/Authprovider.dart';
import 'firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';

class ForumsPage extends StatefulWidget {
  @override
  _ForumsPageState createState() => _ForumsPageState();
}

class _ForumsPageState extends State<ForumsPage> {
  late FirebaseDatabaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _firebaseService = FirebaseDatabaseService(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          if (authProvider.role == 'admin')
            Container(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _showCreateForumDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Create New Forum'),
              ),
            ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _firebaseService.getForumsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.red[700]),
                  );
                }

                final forums = <Map<String, dynamic>>[];
                if (snapshot.data!.snapshot.value != null) {
                  final data =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  data.forEach((key, value) {
                    forums.add({
                      'id': key,
                      ...Map<String, dynamic>.from(value as Map),
                    });
                  });
                }

                forums.sort(
                  (a, b) =>
                      (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0),
                );

                if (forums.isEmpty) {
                  return Center(
                    child: Text(
                      'No forums yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: forums.length,
                  itemBuilder: (context, index) {
                    final forum = forums[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          forum['title'] ?? 'No Title',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(forum['content'] ?? ''),
                            SizedBox(height: 8),
                            Text(
                              'By ${forum['userName'] ?? 'Unknown'} • ${forum['threadCount'] ?? 0} threads',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ForumDetailPage(
                                      forumId: forum['id'],
                                      forumTitle: forum['title'] ?? 'Forum',
                                    ),
                              ),
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateForumDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Create New Forum'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Forum Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      contentController.text.isNotEmpty) {
                    try {
                      await _firebaseService.createForumPost(
                        title: titleController.text,
                        content: contentController.text,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Forum created successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating forum')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
                child: Text('Create', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}

class ForumDetailPage extends StatefulWidget {
  final String forumId;
  final String forumTitle;

  ForumDetailPage({required this.forumId, required this.forumTitle});

  @override
  _ForumDetailPageState createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  late FirebaseDatabaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _firebaseService = FirebaseDatabaseService(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forumTitle),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateThreadDialog(context),
        backgroundColor: Colors.red[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _firebaseService.getForumThreadsStream(widget.forumId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: Colors.red[700]),
            );
          }

          final threads = <Map<String, dynamic>>[];
          if (snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            data.forEach((key, value) {
              threads.add({
                'id': key,
                ...Map<String, dynamic>.from(value as Map),
              });
            });
          }

          threads.sort(
            (a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0),
          );

          if (threads.isEmpty) {
            return Center(
              child: Text(
                'No threads yet. Create the first thread!',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    thread['title'] ?? 'No Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(thread['content'] ?? ''),
                      SizedBox(height: 8),
                      Text(
                        'By ${thread['userName'] ?? 'Unknown'} • ${thread['commentCount'] ?? 0} comments',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ThreadDetailPage(
                                forumId: widget.forumId,
                                threadId: thread['id'],
                                threadTitle: thread['title'] ?? 'Thread',
                              ),
                        ),
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateThreadDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Create New Thread'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Thread Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      contentController.text.isNotEmpty) {
                    try {
                      await _firebaseService.createForumThread(
                        forumId: widget.forumId,
                        title: titleController.text,
                        content: contentController.text,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Thread created successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating thread')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
                child: Text('Create', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}

class ThreadDetailPage extends StatefulWidget {
  final String forumId;
  final String threadId;
  final String threadTitle;

  ThreadDetailPage({
    required this.forumId,
    required this.threadId,
    required this.threadTitle,
  });

  @override
  _ThreadDetailPageState createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> {
  late FirebaseDatabaseService _firebaseService;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _firebaseService = FirebaseDatabaseService(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.threadTitle),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _firebaseService.getThreadCommentsStream(
                widget.forumId,
                widget.threadId,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.red[700]),
                  );
                }

                final comments = <Map<String, dynamic>>[];
                if (snapshot.data!.snapshot.value != null) {
                  final data =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  data.forEach((key, value) {
                    comments.add({
                      'id': key,
                      ...Map<String, dynamic>.from(value as Map),
                    });
                  });
                }

                comments.sort(
                  (a, b) =>
                      (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0),
                );

                if (comments.isEmpty) {
                  return Center(
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment['userName'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        comment['userRole'] == 'admin'
                                            ? Colors.red[700]
                                            : Colors.black,
                                  ),
                                ),
                                if (comment['userRole'] == 'admin')
                                  Container(
                                    margin: EdgeInsets.only(left: 8),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[700],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'ADMIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(comment['content'] ?? ''),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      try {
        await _firebaseService.addThreadComment(
          forumId: widget.forumId,
          threadId: widget.threadId,
          content: _commentController.text,
        );
        _commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding comment')));
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
