import 'classes/pollcomment.dart';
import 'package:flutter/material.dart';
import 'providers/Announcementprovider.dart';
import 'package:provider/provider.dart';

class PollCommentsSection extends StatefulWidget {
  List<PollComment> comments;
  PollCommentsSection({required this.comments});

  @override
  _PollCommentsSectionState createState() => _PollCommentsSectionState();
}

class _PollCommentsSectionState extends State<PollCommentsSection> {
  @override
  Widget build(BuildContext context) {
    final announcementProvider = Provider.of<AnnouncementProvider>(context);
    return ListView.builder(
      itemCount: widget.comments.length,
      itemBuilder: (context, index) {
        var comment = widget.comments[index];
        return ListTile(
          title: Text(comment.text),
          subtitle: Text(comment.userName),
        );
      },
    );
  }
}
