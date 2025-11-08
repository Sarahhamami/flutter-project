import 'package:flutter/material.dart';
import 'friends_list_page.dart';
import '../services/chat_service.dart';
import '../db/database_helper.dart';
import '../models/article.dart';
import 'gif_picker_dialog.dart';
import '../services/gif_service.dart';

// Color palette
const Color kWhite = Colors.white;
const Color kPrimary = Color(0xFF01BCE5);
const Color kDark = Color(0xFF52575A);
const Color kAccent = Color(0xFF08CAC2);

class ChatConversationPage extends StatefulWidget {
  final Friend friend;
  final int currentUserId; // The logged-in user's ID

  const ChatConversationPage({
    super.key,
    required this.friend,
    this.currentUserId = 2, // Default to user ID 1 for demo
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int? _currentUserId;
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🎯 ChatConversationPage initialized');
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final db = DatabaseHelper();
      _currentUserId = await db.getDefaultUserId();
      debugPrint('👤 Loaded current user ID: $_currentUserId');
      setState(() {});
      _loadMessages();
    } catch (e) {
      debugPrint('❌ Error loading current user: $e');
      // Fallback to default ID
      _currentUserId = 1;
      setState(() {});
      _loadMessages();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    if (_currentUserId == null) {
      debugPrint('⏳ Waiting for current user ID to load...');
      return;
    }

    debugPrint('🚀 Starting to load messages for user $_currentUserId and friend ${widget.friend.userId}');
    setState(() {
      _isLoading = true;
      _hasTimedOut = false;
    });

    final currentUserIdStr = _currentUserId.toString();
    final friendUserIdStr = widget.friend.userId.toString();

    // Set up timeout to prevent infinite loading
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        debugPrint('⏰ Message loading timed out after 10 seconds');
        setState(() {
          _isLoading = false;
          _hasTimedOut = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection timeout. Please check your internet connection and Firebase configuration.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

    // Listen to real-time messages from Firebase
    _chatService
        .getMessages(currentUserIdStr, friendUserIdStr)
        .listen((messages) {
      debugPrint('📨 Received ${messages.length} messages from stream');
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
          _hasTimedOut = false;
        });
        _scrollToBottom();
      }
    }, onError: (error) {
      debugPrint('❌ Stream error: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading messages: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Mark messages as read when loading
    _chatService.markAsRead(currentUserIdStr, friendUserIdStr, currentUserIdStr);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserId == null) return;

    final content = _messageController.text.trim();
    debugPrint('💬 Sending message: "$content" from user $_currentUserId to ${widget.friend.userId}');
    _messageController.clear();

    try {
      final currentUserIdStr = _currentUserId.toString();
      final friendUserIdStr = widget.friend.userId.toString();

      await _chatService.sendMessage(
        currentUserIdStr,
        friendUserIdStr,
        content,
      );

      debugPrint('✅ Message sent successfully');
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendGif(GifData gif) async {
    if (_currentUserId == null) return;

    debugPrint('🎭 Sending GIF: ${gif.id} from user $_currentUserId to ${widget.friend.userId}');

    try {
      final currentUserIdStr = _currentUserId.toString();
      final friendUserIdStr = widget.friend.userId.toString();

      // Send GIF URL as a special message format
      final gifMessage = '[GIF:${gif.url}]';

      await _chatService.sendMessage(
        currentUserIdStr,
        friendUserIdStr,
        gifMessage,
      );

      debugPrint('✅ GIF sent successfully');
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error sending GIF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending GIF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          icon: Icon(Icons.arrow_back, color: kDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: const AssetImage('assets/images/splash.png'),
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
                  _getStatusText(widget.friend.status),
                  style: TextStyle(
                    color: _getStatusColor(widget.friend.status),
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : _hasTimedOut
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.signal_wifi_off,
                              size: 64,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Connection Timeout',
                              style: TextStyle(
                                color: kDark.withOpacity(0.7),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unable to connect to chat service.\nPlease check your internet connection.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kDark.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMessages,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary,
                                foregroundColor: kWhite,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: kDark.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    color: kDark.withOpacity(0.5),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start a conversation!',
                                  style: TextStyle(
                                    color: kDark.withOpacity(0.3),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isUser = message.senderId == _currentUserId.toString();
                              return _ChatBubble(
                                message: message,
                                isUser: isUser,
                              );
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
                // GIF button
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => GifPickerDialog(
                          onGifSelected: (gif) {
                            _sendGif(gif);
                          },
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.gif,
                      color: kPrimary,
                      size: 20,
                    ),
                  ),
                ),
                // Send button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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

  String _getStatusText(String status) {
    switch (status) {
      case 'online':
        return 'Online';
      case 'away':
        return 'Away';
      case 'offline':
        return 'Offline';
      default:
        return 'Offline';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return kPrimary;
      case 'away':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const _ChatBubble({
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, color: kPrimary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? kPrimary : kDark.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? kPrimary.withOpacity(0.2)
                        : kDark.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(message, isUser),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: kPrimary.withOpacity(0.1),
              child: const Icon(Icons.person, color: kPrimary, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, bool isUser) {
    // Check if message is a GIF
    final gifRegex = RegExp(r'^\[GIF:(.+)\]$');
    final gifMatch = gifRegex.firstMatch(message.content);

    if (gifMatch != null) {
      final gifUrl = gifMatch.group(1)!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 150,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUser ? kWhite.withOpacity(0.3) : kDark.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                gifUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 75,
                    color: isUser ? kWhite.withOpacity(0.1) : kLightGrey,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 75,
                    color: isUser ? kWhite.withOpacity(0.1) : kLightGrey,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.red,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: isUser
                  ? kWhite.withOpacity(0.7)
                  : kDark.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      );
    } else {
      // Regular text message
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: isUser ? kWhite : kDark,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: isUser
                  ? kWhite.withOpacity(0.7)
                  : kDark.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      );
    }
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
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}