import 'package:firebase_database/firebase_database.dart';
import "providers/Authprovider.dart";
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class FirebaseDatabaseService {
  final AuthProvider _authProvider;
  late final DatabaseReference _database;

  FirebaseDatabaseService(this._authProvider) {
    // Initialize Firebase Database reference
    _database = FirebaseDatabase.instance.ref();

    // Set the authentication
    _configureFirebaseAuth();
  }

  // Configure Firebase authentication with the token
  void _configureFirebaseAuth() {
    if (_authProvider.token.isNotEmpty) {
      // This is the proper way to authenticate with Firebase
      FirebaseDatabase.instance.app.setAutomaticDataCollectionEnabled(true);

      // Set the database URL without appending the token (it's handled internally)
      FirebaseDatabase.instance.databaseURL =
          'https://mobile-project-f3d15-default-rtdb.europe-west1.firebasedatabase.app';
    }
  }

  // Get messages reference
  DatabaseReference get messagesRef => _database.child('messages');

  // Get forums reference
  DatabaseReference get forumsRef => _database.child('forums');

  // Check if user is authenticated before performing operations
  bool _isUserAuthenticated() {
    return _authProvider.isAuthenticated && _authProvider.token.isNotEmpty;
  }

  // Create a new message
  Future<String> createMessage({
    required String content,
    bool isFromGovernment = false,
  }) async {
    if (!_isUserAuthenticated()) {
      throw Exception('User is not authenticated');
    }
    try {
      // Generate a new unique key for the message
      final newMessageRef = messagesRef.push();
      final String messageId = newMessageRef.key!;

      // Set the message data
      await newMessageRef.set({
        'senderName': _authProvider.name,
        'content': content,
        'timestamp': ServerValue.timestamp,
        'isFromGovernment': isFromGovernment || _authProvider.role == 'admin',
        'userId': _authProvider.userId,
      });
      return messageId;
    } catch (e) {
      print('Error creating message: $e');
      throw e;
    }
  }

  // Send a chat message in an existing conversation
  Future<void> sendChatMessage({
    required String messageId,
    required String content,
  }) async {
    if (!_isUserAuthenticated()) {
      throw Exception('User is not authenticated');
    }
    try {
      // Reference to the chat messages for this conversation
      final chatRef = messagesRef.child(messageId).child('chat').push();

      // Set the chat message data
      await chatRef.set({
        'content': content,
        'timestamp': ServerValue.timestamp,
        'isFromGovernment': _authProvider.role == 'admin',
        'senderName': _authProvider.name,
        'userId': _authProvider.userId,
      });
    } catch (e) {
      print('Error sending chat message: $e');
      throw e;
    }
  }

  // Stream of messages for the messages page
  Stream<DatabaseEvent> getMessagesStream() {
    return messagesRef.orderByChild('timestamp').onValue;
  }

  // Stream of chat messages for a conversation
  Stream<DatabaseEvent> getChatMessagesStream(String messageId) {
    return messagesRef
        .child(messageId)
        .child('chat')
        .orderByChild('timestamp')
        .onValue;
  }

  // Forum related methods
  // Create a new forum post
  Future<String> createForumPost({
    required String title,
    required String content,
  }) async {
    if (!_isUserAuthenticated()) {
      throw Exception('User is not authenticated');
    }
    try {
      // Generate a new unique key for the forum post
      final newForumRef = forumsRef.push();
      final String forumId = newForumRef.key!;

      // Set the forum post data
      await newForumRef.set({
        'title': title,
        'content': content,
        'timestamp': ServerValue.timestamp,
        'userId': _authProvider.userId,
        'userName': _authProvider.name,
        'commentCount': 0,
        'userRole': _authProvider.role,
      });
      return forumId;
    } catch (e) {
      print('Error creating forum post: $e');
      throw e;
    }
  }

  // Add a comment to a forum post
  Future<String> addForumComment({
    required String forumId,
    required String content,
  }) async {
    if (!_isUserAuthenticated()) {
      throw Exception('User is not authenticated');
    }
    try {
      // Reference to the comments for this forum post
      final commentsRef = forumsRef.child(forumId).child('comments');
      // Generate a new unique key for the comment
      final newCommentRef = commentsRef.push();
      final String commentId = newCommentRef.key!;

      // Set the comment data
      await newCommentRef.set({
        'content': content,
        'timestamp': ServerValue.timestamp,
        'userId': _authProvider.userId,
        'userName': _authProvider.name,
        'userRole': _authProvider.role,
      });

      // Update comment count
      await forumsRef
          .child(forumId)
          .child('commentCount')
          .set(ServerValue.increment(1));

      return commentId;
    } catch (e) {
      print('Error adding forum comment: $e');
      throw e;
    }
  }

  // Stream of forums for the forums page
  Stream<DatabaseEvent> getForumsStream() {
    return forumsRef.orderByChild('timestamp').onValue;
  }

  // Stream of comments for a specific forum post
  Stream<DatabaseEvent> getForumCommentsStream(String forumId) {
    return forumsRef
        .child(forumId)
        .child('comments')
        .orderByChild('timestamp')
        .onValue;
  }

  // Get threads for a specific forum
  Stream<DatabaseEvent> getForumThreadsStream(String forumId) {
    return _database.child('forums/$forumId/threads').onValue;
  }

  // Create a new thread in a forum
  Future<void> createForumThread({
    required String forumId,
    required String title,
    required String content,
  }) async {
    if (!_isUserAuthenticated()) {
      throw Exception('User not authenticated');
    }

    final threadRef = _database.child('forums/$forumId/threads').push();
    await threadRef.set({
      'title': title,
      'content': content,
      'userId': _authProvider.userId,
      'userName': _authProvider.name,
      'userRole': _authProvider.role,
      'timestamp': ServerValue.timestamp,
      'commentCount': 0,
    });

    // Update forum thread count
    final forumRef = _database.child('forums/$forumId');
    await forumRef.child('threadCount').set(ServerValue.increment(1));
  }

  // Get comments for a specific thread
  Stream<DatabaseEvent> getThreadCommentsStream(
    String forumId,
    String threadId,
  ) {
    return _database
        .child('forums/$forumId/threads/$threadId/comments')
        .onValue;
  }

  // Add comment to a thread
  Future<void> addThreadComment({
    required String forumId,
    required String threadId,
    required String content,
  }) async {
    if (!_isUserAuthenticated()) {
      throw Exception('User not authenticated');
    }

    final commentRef =
        _database.child('forums/$forumId/threads/$threadId/comments').push();
    await commentRef.set({
      'content': content,
      'userId': _authProvider.userId,
      'userName': _authProvider.name,
      'userRole': _authProvider.role,
      'timestamp': ServerValue.timestamp,
    });

    // Update thread comment count
    final threadRef = _database.child('forums/$forumId/threads/$threadId');
    await threadRef.child('commentCount').set(ServerValue.increment(1));
  }
}
