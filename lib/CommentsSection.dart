import 'package:flutter/material.dart';
import 'package:bgam3/classes/comment.dart';
import 'package:bgam3/providers/Announcementprovider.dart';
import 'package:provider/provider.dart';

class CommentsSection extends StatefulWidget {
  final List<Comment> comments;

  const CommentsSection({Key? key, required this.comments}) : super(key: key);

  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  @override
  Widget build(BuildContext context) {
    return widget.comments.isEmpty
        ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No comments yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: widget.comments.length,
          itemBuilder: (context, index) {
            final comment = widget.comments[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(comment.text, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(
                        comment.date,
                      ), // Add timestamp formatting if available
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
