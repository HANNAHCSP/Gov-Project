import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_service.dart';
import 'providers/Authprovider.dart';
import 'shared_components_messages.dart';

class ChatPage extends StatefulWidget {
  final String senderName;
  final String messageId;
  final String userRole;
  final String userName;

  ChatPage({
    required this.senderName,
    required this.messageId,
    required this.userRole,
    required this.userName,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late FirebaseDatabaseService _databaseService;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _databaseService = FirebaseDatabaseService(
      Provider.of<AuthProvider>(context, listen: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.userRole == 'admin';

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Chat with ${widget.senderName}'),
        actions: [],
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(child: _buildChatMessages()),

          // Message input area
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Build chat messages from stream
  Widget _buildChatMessages() {
    return StreamBuilder<DatabaseEvent>(
      stream: _databaseService.getChatMessagesStream(widget.messageId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to load messages'));
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _buildEmptyChatState();
        }

        // Get chat messages
        final chatData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<ChatMessage> chatMessages = _processChatMessages(chatData);

        // Sort by timestamp (oldest first)
        chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Auto scroll to bottom
        _scrollToBottom();

        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.all(16),
          itemCount: chatMessages.length,
          itemBuilder: (context, index) {
            final message = chatMessages[index];
            return ChatBubble(
              chatMessage: message,
              isCurrentUser: widget.userName == message.senderName,
            );
          },
        );
      },
    );
  }

  // Process chat messages from Firebase data
  List<ChatMessage> _processChatMessages(Map<dynamic, dynamic> chatData) {
    List<ChatMessage> messages = [];

    chatData.forEach((key, value) {
      if (value is Map<dynamic, dynamic>) {
        messages.add(ChatMessage.fromMap(key, value));
      }
    });

    return messages;
  }

  // Scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Empty chat state
  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text('No messages yet'),
          Text('Start the conversation!'),
        ],
      ),
    );
  }

  // Message input field and send button
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          // Text input
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),

          // Send button
          CircleAvatar(
            backgroundColor: Colors.red[800],
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // Send a message
  void _sendMessage() {
    String messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    // Clear input immediately
    messageController.clear();

    try {
      // Send chat message
      _databaseService.sendChatMessage(
        messageId: widget.messageId,
        content: messageText,
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message. Please try again.')),
      );
      // Restore message if failed
      messageController.text = messageText;
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
