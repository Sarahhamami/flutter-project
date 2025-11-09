import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map, String messageId) {
    return ChatMessage(
      messageId: messageId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }
}

class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get or create conversation ID
  String _getConversationId(String userId1, String userId2) {
    // Always create the same conversation ID regardless of order
    final sortedIds = [userId1, userId2]..sort();
    return 'conversation_${sortedIds[0]}_${sortedIds[1]}';
  }

  // Send a message
  Future<void> sendMessage(String senderId, String receiverId, String content) async {
    try {
      final conversationId = _getConversationId(senderId, receiverId);
      debugPrint('📤 Sending message to conversation: $conversationId');
      debugPrint('📤 Message content: $content');

      final messageRef = _database.child('messages/$conversationId').push();

      final messageData = {
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isRead': false,
      };

      await messageRef.set(messageData);
      debugPrint('✅ Message sent successfully to Firebase');

      // Update conversation metadata
      await _database.child('conversations/$conversationId').update({
        'lastMessage': content,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'user1': senderId.compareTo(receiverId) < 0 ? senderId : receiverId,
        'user2': senderId.compareTo(receiverId) < 0 ? receiverId : senderId,
      });
      debugPrint('✅ Conversation metadata updated');
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      throw Exception('Error sending message: $e');
    }
  }

  // Get messages for a conversation (real-time stream)
  Stream<List<ChatMessage>> getMessages(String userId1, String userId2) {
    final conversationId = _getConversationId(userId1, userId2);

    debugPrint('🔄 Setting up message stream for conversation: $conversationId');

    return _database
        .child('messages/$conversationId')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      debugPrint('📡 Firebase stream emitted event for conversation: $conversationId');
      debugPrint('📊 Event snapshot exists: ${event.snapshot.exists}');
      debugPrint('📊 Event snapshot value: ${event.snapshot.value}');

      final data = event.snapshot.value;
      if (data == null) {
        debugPrint('📭 No messages found for conversation: $conversationId');
        return <ChatMessage>[];
      }

      final messages = <ChatMessage>[];
      (data as Map).forEach((key, value) {
        messages.add(ChatMessage.fromMap(value as Map, key.toString()));
      });

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      debugPrint('✅ Loaded ${messages.length} messages for conversation: $conversationId');
      return messages;
    });
  }

  // Mark messages as read
  Future<void> markAsRead(String userId1, String userId2, String currentUserId) async {
    try {
      final conversationId = _getConversationId(userId1, userId2);
      final messagesRef = _database.child('messages/$conversationId');
      
      final snapshot = await messagesRef.orderByChild('receiverId').equalTo(currentUserId).get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        for (var entry in data.entries) {
          if ((entry.value as Map)['isRead'] != true) {
            await messagesRef.child(entry.key.toString()).update({'isRead': true});
          }
        }
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Get conversation last message for friends list
  Future<String?> getLastMessage(String userId1, String userId2) async {
    try {
      final conversationId = _getConversationId(userId1, userId2);
      final snapshot = await _database.child('conversations/$conversationId/lastMessage').get();
      return snapshot.value as String?;
    } catch (e) {
      return null;
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId1, String userId2, String currentUserId) async {
    try {
      final conversationId = _getConversationId(userId1, userId2);
      final snapshot = await _database.child('messages/$conversationId').get();
      
      if (!snapshot.exists) return 0;

      int count = 0;
      final data = snapshot.value as Map;
      for (var entry in data.entries) {
        final message = entry.value as Map;
        if (message['receiverId'] == currentUserId && message['isRead'] == false) {
          count++;
        }
      }
      return count;
    } catch (e) {
      return 0;
    }
  }
}
