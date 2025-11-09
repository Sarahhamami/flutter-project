import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/article.dart';
import 'friends_list_page.dart';
import 'chat_conversation_page.dart';
import 'package:firebase_database/firebase_database.dart';

// Color palette
const Color kWhite = Colors.white;
const Color kPrimary = Color(0xFF01BCE5);
const Color kDark = Color(0xFF52575A);
const Color kAccent = Color(0xFF08CAC2);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatFriend> _friends = [];
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _setupConversationListener();
  }

  @override
  void dispose() {
    // Clean up listener if needed
    super.dispose();
  }
  
  Future<void> _loadCurrentUser() async {
    try {
      final db = DatabaseHelper();
      _currentUserId = await db.getDefaultUserId();
      debugPrint('👤 ChatPage loaded current user ID: $_currentUserId');
      await _loadFriends();
    } catch (e) {
      debugPrint('❌ Error loading current user in ChatPage: $e');
      _currentUserId = 1; // Fallback
      await _loadFriends();
    }
  }

  Future<void> _loadFriends() async {
    try {
      final db = DatabaseHelper();
      final users = await db.getAllUsers();

      debugPrint('📊 Total users in database: ${users.length}');
      for (var user in users) {
        debugPrint('👤 User ID: ${user['user_id']}, Name: ${user['prenom']} ${user['nom']}, Email: ${user['email']}');
      }

      _friends.clear();
      for (var user in users) {
        // Don't add current user to friends list
        if (user['user_id'] != _currentUserId) {
          debugPrint('➕ Adding friend: ${user['prenom']} ${user['nom']} (ID: ${user['user_id']})');
          final friendUser = User.fromMap(user);
          _friends.add(ChatFriend(
            id: friendUser.userId.toString(),
            name: friendUser.fullName,
            lastMessage: 'Start a conversation!', // Default message
            timestamp: DateTime.now(),
            isOnline: false, // TODO: Implement online status
            unreadCount: 0, // TODO: Load from Firebase
            avatar: 'assets/images/splash.png',
          ));
        } else {
          debugPrint('🚫 Skipping current user: ${user['prenom']} ${user['nom']} (ID: ${user['user_id']})');
        }
      }

      debugPrint('👥 Loaded ${_friends.length} friends from database (excluding current user)');
      debugPrint('🎯 Current user ID: $_currentUserId');

      // Debug: Show which friends were loaded for current user
      debugPrint('👥 Friends list for user $_currentUserId:');
      for (var friend in _friends) {
        debugPrint('   - ${friend.name} (ID: ${friend.id})');
      }

      // Load conversation data from Firebase
      await _loadConversationsFromFirebase();

      // Force UI update
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error loading friends: $e');
      debugPrint('❌ Error details: ${e.toString()}');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      // Fallback to some default friends for testing
      _loadFallbackFriends();
    }
  }

  void _loadFallbackFriends() {
    debugPrint('⚠️ Loading fallback friends - this should not happen if database works');
    _friends.clear();
    _friends.addAll([
      ChatFriend(
        id: '2',
        name: 'Dr. Sarah Johnson',
        lastMessage: 'Thanks for sharing your symptoms. Let me know how you feel tomorrow.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isOnline: true,
        unreadCount: 2,
        avatar: 'assets/images/splash.png',
      ),
      ChatFriend(
        id: '3',
        name: 'Mike Chen',
        lastMessage: 'Hey! How was your workout today?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isOnline: false,
        unreadCount: 0,
        avatar: 'assets/images/splash.png',
      ),
    ]);
    setState(() {});
  }

  Future<void> _loadConversationsFromFirebase() async {
    if (_currentUserId == null) return;

    try {
      debugPrint('🔄 Loading conversations from Firebase for user $_currentUserId');

      // First, let's check what's actually in Firebase
      final rootRef = FirebaseDatabase.instance.ref();
      final rootSnapshot = await rootRef.get();
      debugPrint('🌳 Firebase root data: ${rootSnapshot.value}');

      final conversationsRef = FirebaseDatabase.instance
          .ref()
          .child('conversations');

      final snapshot = await conversationsRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        debugPrint('📊 Found ${data.length} conversations in Firebase');
        debugPrint('📋 Conversation keys: ${data.keys.toList()}');
        debugPrint('📋 Full conversation data: $data');

        // Update friends with real conversation data
        for (var friend in _friends) {
          final friendId = int.parse(friend.id);
          final conversationId = _getConversationId(_currentUserId!, friendId);
          debugPrint('🔍 Checking conversation: $conversationId for friend ${friend.name} (ID: $friendId)');

          if (data.containsKey(conversationId)) {
            final convData = data[conversationId] as Map;
            final lastMessage = convData['lastMessage'];
            final lastMessageTime = convData['lastMessageTime'];

            debugPrint('📝 Raw conversation data for $conversationId: $convData');
            debugPrint('📝 Extracted: lastMessage="$lastMessage", lastMessageTime=$lastMessageTime');

            if (lastMessage != null && lastMessage.toString().isNotEmpty) {
              friend.lastMessage = lastMessage.toString();
              debugPrint('✅ Updated ${friend.name} with last message: "${friend.lastMessage}"');
            } else {
              debugPrint('⚠️ Empty or null lastMessage for ${friend.name}');
            }

            if (lastMessageTime != null) {
              try {
                friend.timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(lastMessageTime.toString()));
                debugPrint('✅ Updated ${friend.name} timestamp to ${friend.timestamp}');
              } catch (e) {
                debugPrint('⚠️ Error parsing timestamp for ${friend.name}: $e');
              }
            } else {
              debugPrint('⚠️ No lastMessageTime found for ${friend.name}');
            }
          } else {
            debugPrint('❌ Conversation $conversationId not found for ${friend.name}');
          }
        }

        debugPrint('🔄 Calling setState to update UI');
        if (mounted) {
          setState(() {});
        }

        // Debug: Print final friend states
        for (var friend in _friends) {
          debugPrint('🎯 Final state for ${friend.name}: lastMessage="${friend.lastMessage}", timestamp=${friend.timestamp}');
        }
      } else {
        debugPrint('📭 No conversations found in Firebase');
      }
    } catch (e) {
      debugPrint('❌ Error loading conversations from Firebase: $e');
      debugPrint('❌ Error details: ${e.toString()}');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
    }
  }

  void _setupConversationListener() {
    debugPrint('👂 Setting up conversation listener');
    FirebaseDatabase.instance
        .ref()
        .child('conversations')
        .onValue
        .listen((event) {
          debugPrint('📡 Conversations updated in Firebase');
          if (_currentUserId != null && mounted) {
            _loadConversationsFromFirebase();
          }
        }, onError: (error) {
          debugPrint('❌ Conversation listener error: $error');
        });
  }

  String _getConversationId(int user1, int user2) {
    final sorted = [user1, user2]..sort();
    return 'conversation_${sorted[0]}_${sorted[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: kDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: kPrimary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Friends list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return _FriendCard(
                  friend: friend,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatConversationPage(
                          friend: Friend(
                            userId: int.parse(friend.id),
                            name: friend.name,
                            avatar: friend.avatar,
                            status: friend.isOnline ? 'online' : 'offline',
                            lastMessage: friend.lastMessage,
                            lastMessageTime: friend.timestamp,
                          ),
                          currentUserId: _currentUserId ?? 1,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new chat functionality
        },
        backgroundColor: kPrimary,
        child: const Icon(Icons.add, color: kWhite),
      ),
    );
  }
}

class ChatFriend {
  final String id;
  final String name;
  String lastMessage;
  DateTime timestamp;
  final bool isOnline;
  final int unreadCount;
  final String avatar;

  ChatFriend({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.isOnline,
    required this.unreadCount,
    required this.avatar,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Individual Chat Page
class IndividualChatPage extends StatefulWidget {
  final ChatFriend friend;

  const IndividualChatPage({super.key, required this.friend});

  @override
  State<IndividualChatPage> createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    _messages.addAll([
      ChatMessage(
        text: "Hi! How are you feeling today?",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        text: "I'm doing well, thanks for asking! How about you?",
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      ChatMessage(
        text: "I'm great! Just finished my morning workout. Any plans for the weekend?",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      ChatMessage(
        text: "Thinking of going for a hike. Want to join?",
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate friend response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "That sounds amazing! I'd love to join you.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(widget.friend.avatar),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.name,
                  style: TextStyle(
                    color: kDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.friend.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: widget.friend.isOnline ? kPrimary : kDark.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.more_vert, color: kPrimary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              boxShadow: [
                BoxShadow(
                  color: kDark.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kDark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: kDark.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: kDark.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimary, kAccent],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: kWhite,
                      size: 20,
                    ),
                  ),
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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Friend Card Widget
class _FriendCard extends StatelessWidget {
  final ChatFriend friend;
  final VoidCallback onTap;

  const _FriendCard({
    required this.friend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kDark.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: kDark.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with online status
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(friend.avatar),
                    ),
                    if (friend.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: kPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: kWhite, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Friend info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            friend.name,
                            style: TextStyle(
                              color: kDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatTime(friend.timestamp),
                            style: TextStyle(
                              color: kDark.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              friend.lastMessage,
                              style: TextStyle(
                                color: kDark.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (friend.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                friend.unreadCount.toString(),
                                style: const TextStyle(
                                  color: kWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: kPrimary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: kPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? kPrimary 
                    : kDark.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message.isUser 
                      ? const Radius.circular(20) 
                      : const Radius.circular(4),
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser 
                        ? kPrimary.withOpacity(0.2) 
                        : kDark.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? kWhite : kDark,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? kWhite.withOpacity(0.7) 
                          : kDark.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: kPrimary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: kPrimary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
