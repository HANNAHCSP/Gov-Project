import 'package:flutter/material.dart';

// Simple data models
class Message {
  final String id;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isFromGovernment;

  Message({
    required this.id,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isFromGovernment = false,
  });

  // Create from Firebase data
  static Message fromMap(String id, Map<dynamic, dynamic> data) {
    return Message(
      id: id,
      senderName: data['senderName'] ?? '',
      content: data['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
      isFromGovernment: data['isFromGovernment'] ?? false,
    );
  }
}

class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final String senderName;
  final bool isFromGovernment;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.senderName,
    this.isFromGovernment = false,
  });

  // Create from Firebase data
  static ChatMessage fromMap(String id, Map<dynamic, dynamic> data) {
    return ChatMessage(
      id: id,
      content: data['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
      senderName: data['senderName'] ?? '',
      isFromGovernment: data['isFromGovernment'] ?? false,
    );
  }
}

// Message tile widget
class MessageTile extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;

  MessageTile({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAvatarColor(message.senderName),
          child: Text(
            message.senderName.isNotEmpty
                ? message.senderName[0].toUpperCase()
                : '?',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontWeight:
                      message.isFromGovernment
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
            Text(
              _formatTimeAgo(message.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Text(
          message.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            message.isFromGovernment
                ? Icon(Icons.verified, color: Colors.blue)
                : null,
        onTap: onTap,
      ),
    );
  }

  // Get avatar color based on name
  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.red[400]!,
    ];
    return colors[name.hashCode % colors.length];
  }

  // Format time as relative string
  String _formatTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

// Chat bubble widget
class ChatBubble extends StatelessWidget {
  final ChatMessage chatMessage;
  final bool isCurrentUser;

  ChatBubble({required this.chatMessage, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    // Determine if this is a government message
    final bool isGovernmentMessage = chatMessage.isFromGovernment;

    // For admin/government messages, we want them to appear on the right side
    // when they are sent by the current user (admin)
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _getBubbleColor(),
          borderRadius: BorderRadius.circular(18),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender name for other user's messages
            if (!isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  chatMessage.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isGovernmentMessage ? Colors.red : Colors.black87,
                  ),
                ),
              ),

            // Message content
            Text(
              chatMessage.content,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
              ),
            ),

            // Time and verification
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(chatMessage.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (chatMessage.isFromGovernment && !isCurrentUser)
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.verified, size: 12, color: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Get bubble color based on sender
  Color _getBubbleColor() {
    if (isCurrentUser) {
      return Colors.red[600]!;
    } else if (chatMessage.isFromGovernment) {
      return Colors.grey[300]!;
    } else {
      return Colors.blue[300]!;
    }
  }

  // Format time as HH:MM
  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
