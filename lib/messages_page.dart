import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_service.dart';
import 'providers/Authprovider.dart';
import 'chat_page.dart';
import 'shared_components_messages.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late FirebaseDatabaseService _databaseService;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _databaseService = FirebaseDatabaseService(
      Provider.of<AuthProvider>(context, listen: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Hi, ${authProvider.name}',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search messages',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFFECEFF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Messages list
          Expanded(child: _buildMessagesList()),
        ],
      ),
      // Show FAB only for non-admin users
      floatingActionButton:
          authProvider.role != 'admin'
              ? FloatingActionButton(
                onPressed: () => _showNewMessageDialog(),
                backgroundColor: Colors.red[800],
                child: Icon(Icons.add_comment, color: Colors.white),
              )
              : null,
    );
  }

  // Show dialog to create a new message
void _showNewMessageDialog() {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Send a Message to Government',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Message Input Field
                  TextField(
                    controller: messageController,
                    maxLines: 5,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.red[800]!),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                        child: Text('Cancel', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final message = messageController.text.trim();
                          if (message.isEmpty) return;

                          Navigator.of(ctx).pop();
                          _createNewMessage(message);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[800],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }


  // Create a new message and handle the response
  Future<void> _createNewMessage(String message) async {
    try {
      // Create the initial message
      String messageId = await _databaseService.createMessage(content: message);

      // Add as first chat message
      await _databaseService.sendChatMessage(
        messageId: messageId,
        content: message,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent successfully!'),
          backgroundColor: const Color.fromARGB(255, 69, 145, 72),
        ),
      );

      // Navigate to chat
      _openChat(messageId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Open chat page
  void _openChat(String messageId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatPage(
              senderName: authProvider.name,
              messageId: messageId,
              userRole: authProvider.role,
              userName: authProvider.name,
            ),
      ),
    );
  }

  // Build the messages list
  Widget _buildMessagesList() {
    final authProvider = Provider.of<AuthProvider>(context);

    return StreamBuilder<DatabaseEvent>(
      stream: _databaseService.getMessagesStream(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Failed to load messages'),
              ],
            ),
          );
        }

        // Empty state
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _buildEmptyState();
        }

        // Process messages
        final messagesData =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<Message> messages = _processMessages(messagesData);

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          messages =
              messages.where((msg) {
                return msg.senderName.toLowerCase().contains(searchQuery) ||
                    msg.content.toLowerCase().contains(searchQuery);
              }).toList();
        }

        // Sort messages by timestamp (newest first)
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        // Show filtered empty state
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text('No messages found'),
                Text('Try a different search term'),
              ],
            ),
          );
        }

        // Message list
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return MessageTile(
              message: message,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChatPage(
                          senderName: message.senderName,
                          messageId: message.id,
                          userRole: authProvider.role,
                          userName: authProvider.name,
                        ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Process messages from Firebase data
  List<Message> _processMessages(Map<dynamic, dynamic> messagesData) {
    List<Message> messages = [];

    messagesData.forEach((key, value) {
      if (value is Map<dynamic, dynamic>) {
        messages.add(Message.fromMap(key, value));
      }
    });

    return messages;
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.add_comment),
            label: Text('Send a Message'),
            onPressed: () => _showNewMessageDialog(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
