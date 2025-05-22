import 'package:flutter/material.dart';
import 'package:bgam3/AnnouncementCardBasic.dart';
import 'package:provider/provider.dart';
import 'providers/Announcementprovider.dart';
import 'classes/announcement.dart';
import 'providers/Authprovider.dart';
import 'classes/comment.dart';
import 'CommentsSection.dart';

class AnnouncementInfoPage extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementInfoPage({Key? key, required this.announcement})
    : super(key: key);

  @override
  _AnnouncementInfoPageState createState() => _AnnouncementInfoPageState();
}

class _AnnouncementInfoPageState extends State<AnnouncementInfoPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final announcementProvider = Provider.of<AnnouncementProvider>(context);

    List<Comment> comments =
        announcementProvider.comments
            .where(
              (element) => element.announcementId == widget.announcement.id,
            )
            .toList();

    Future<void> postComment() async {
      if (_commentController.text.trim().isEmpty) return;

      await announcementProvider.postComment(
        widget.announcement.id,
        authProvider.userId,
        authProvider.name,
        authProvider.token,
        _commentController.text.trim(),
      );
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Announcement Details'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          AnnouncementCardBasic(announcement: widget.announcement),
          Expanded(child: CommentsSection(comments: comments)),
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(icon: Icon(Icons.send), onPressed: postComment),
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
