import 'package:flutter/material.dart';
import 'package:bgam3/classes/poll.dart';
import 'package:bgam3/classes/pollcomment.dart';
import 'package:bgam3/providers/PollsProvider.dart';
import 'package:provider/provider.dart';
import 'providers/Authprovider.dart';
import 'PollCommentsSection.dart';

class PollInfoCard extends StatefulWidget {
  final Poll poll;
  const PollInfoCard({Key? key, required this.poll}) : super(key: key);

  @override
  _PollInfoCardState createState() => _PollInfoCardState();
}

class _PollInfoCardState extends State<PollInfoCard> {
  bool anonymous = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pollProvider = Provider.of<PollsProvider>(context);
    final comments = pollProvider.pollComments;

    Future<void> postComment() async {
      if (_commentController.text.trim().isEmpty) return;

      final username = anonymous ? "Anonymous" : authProvider.name;
      final userId = anonymous ? "Anonymous" : authProvider.userId;

      await pollProvider.postPollComment(
        authProvider.token,
        userId,
        username,
        widget.poll.id,
        _commentController.text.trim(),
      );
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Discussion'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.poll.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.poll.options.map(
                    (option) =>
                        Text('• $option', style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),

          Expanded(child: PollCommentsSection(comments: comments)),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                // Anonymous Toggle
                IconButton(
                  onPressed: () => setState(() => anonymous = !anonymous),
                  icon: Icon(
                    anonymous ? Icons.visibility_off : Icons.visibility,
                    color: anonymous ? Colors.blue : Colors.grey,
                  ),
                  tooltip:
                      anonymous ? 'Posting as Anonymous' : 'Post as Anonymous',
                ),

                // Comment Input
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => postComment(),
                  ),
                ),

                // Send Button
                IconButton(
                  onPressed: postComment,
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
