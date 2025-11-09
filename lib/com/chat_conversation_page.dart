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
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimary.withOpacity(0.8),
                kAccent.withOpacity(0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Back button with glass effect
                  Container(
                    decoration: BoxDecoration(
                      color: kWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: kWhite.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: kWhite, size: 22),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Enhanced avatar with glowing effect
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kWhite.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: kWhite.withOpacity(0.9),
                          backgroundImage: const AssetImage('assets/images/splash.png'),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.friend.status),
                            border: Border.all(color: kWhite, width: 3),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getStatusColor(widget.friend.status).withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.friend.name,
                          style: TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            shadows: [
                              Shadow(
                                color: kDark.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: kWhite.withOpacity(0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: kWhite.withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusText(widget.friend.status),
                              style: TextStyle(
                                color: kWhite.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: kDark.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Menu button with glass effect
                  Container(
                    decoration: BoxDecoration(
                      color: kWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: kWhite.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, color: kWhite, size: 22),
                      onPressed: () {},
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Chat messages with enhanced background
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kWhite.withOpacity(0.8),
                    kWhite.withOpacity(0.4),
                  ],
                ),
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    )
                  : _hasTimedOut
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.signal_wifi_off,
                                  size: 48,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Connection Timeout',
                                style: TextStyle(
                                  color: kDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Unable to connect to chat service.\nPlease check your internet connection.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: kDark.withOpacity(0.7),
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [kPrimary, kAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kPrimary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _loadMessages,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  ),
                                  child: const Text(
                                    'Retry Connection',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [kPrimary.withOpacity(0.1), kAccent.withOpacity(0.1)],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: kPrimary.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: kPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Start the Conversation',
                                    style: TextStyle(
                                      color: kDark,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Send a message to begin chatting with\n${widget.friend.name}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: kDark.withOpacity(0.7),
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: kPrimary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.waving_hand,
                                          color: kPrimary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Say Hello! 👋',
                                          style: TextStyle(
                                            color: kPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(20),
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
          ),
          // Enhanced Message input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kWhite,
              boxShadow: [
                BoxShadow(
                  color: kDark.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: kPrimary.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kDark.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: kDark.withOpacity(0.6),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.message_outlined,
                            color: kPrimary.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // GIF button with enhanced styling
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimary.withOpacity(0.1), kAccent.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                      Icons.gif_box_outlined,
                      color: kPrimary,
                      size: 24,
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button with enhanced styling
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: kWhite,
                      size: 22,
                    ),
                    padding: const EdgeInsets.all(14),
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
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: const AssetImage('assets/images/splash.png'),
                child: const Icon(Icons.person, color: kPrimary, size: 18),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? kPrimary : kWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: isUser ? const Radius.circular(24) : const Radius.circular(6),
                  bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? kPrimary.withOpacity(0.25)
                        : kDark.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isUser ? null : Border.all(
                  color: kDark.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: _buildMessageContent(message, isUser),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: kPrimary.withOpacity(0.1),
                backgroundImage: const AssetImage('assets/images/splash.png'),
                child: const Icon(Icons.person, color: kPrimary, size: 18),
              ),
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
          const SizedBox(height: 6),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: isUser
                  ? kWhite.withOpacity(0.8)
                  : kDark.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: isUser
                      ? kWhite.withOpacity(0.8)
                      : kDark.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.done_all,
                  size: 14,
                  color: kWhite.withOpacity(0.8),
                ),
              ],
            ],
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