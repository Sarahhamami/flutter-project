import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;

class ChatFitness extends StatefulWidget {
  const ChatFitness({super.key});

  @override
  _ChatFitnessState createState() => _ChatFitnessState();
}

class _ChatFitnessState extends State<ChatFitness> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _showEmojiPicker = false;
  final String _apiKey = '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';
  final Color _primaryColor = const Color(0xFF20c997);
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add initial bot greeting
    _messages.add(
      Message(
        text: "Hello! I'm your fitness coach. How can I help you with your fitness goals today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'mistralai/mixtral-8x7b-instruct',
          'messages': [
            {"role": "system", "content": "You are a helpful fitness coach. Provide clear, actionable fitness and nutrition advice. Keep responses concise and easy to understand."},
            {"role": "user", "content": text}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final botResponse = responseData['choices'][0]['message']['content'];
        
        setState(() {
          _messages.add(
            Message(
              text: botResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      } else {
        setState(() {
          _messages.add(
            Message(
              text: 'Sorry, I encountered an error. Please try again.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          Message(
            text: 'Connection error. Please check your internet connection.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f7fa),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF20c997),
                const Color(0xFF20c997).withOpacity(0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fitness_center, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hamma Coach',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Online',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFf8f9fa),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF20c997)),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser)
            Hero(
              tag: 'bot-avatar',
              child: Container(
                margin: const EdgeInsets.only(right: 8.0, bottom: 20.0),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF20c997), Color(0xFF12b0ff)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF20c997).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 18),
                ),
              ),
            ),
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(0),
              transformAlignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF20c997), Color(0xFF12b0ff)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: message.isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24.0),
                  topRight: const Radius.circular(24.0),
                  bottomLeft: Radius.circular(message.isUser ? 24.0 : 8.0),
                  bottomRight: Radius.circular(message.isUser ? 8.0 : 24.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      color: message.isUser ? Colors.white : const Color(0xFF2d3748),
                      fontSize: 15.0,
                      height: 1.5,
                      fontWeight: message.isUser ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    '${_formatTime(message.timestamp)} • ${_formatDate(message.timestamp)}',
                    style: GoogleFonts.poppins(
                      color: message.isUser ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                      fontSize: 10.0,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser)
            Hero(
              tag: 'user-avatar',
              child: Container(
                margin: const EdgeInsets.only(left: 8.0, bottom: 20.0),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF20c997), Color(0xFF12b0ff)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF20c997).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime time) {
    return '${time.day}/${time.month}/${time.year}';
  }

  void _onEmojiSelected(emoji_picker.Category? category, emoji_picker.Emoji emoji) {
    setState(() {
      _messageController.text = _messageController.text + emoji.emoji;
    });
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: emoji_picker.EmojiPicker(
        onEmojiSelected: _onEmojiSelected,
        config: const emoji_picker.Config(
          // Using only the most basic configuration
          categoryViewConfig: emoji_picker.CategoryViewConfig(
            backgroundColor: Color(0xFFf5f7fa),
            indicatorColor: Color(0xFF20c997),
          ),
          emojiViewConfig: emoji_picker.EmojiViewConfig(
            backgroundColor: Color(0xFFf5f7fa),
          ),
        ),
      ),
    );
  }

Widget _buildMessageInput() {
  return Column(
    children: [
      if (_showEmojiPicker) _buildEmojiPicker(),
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20.0,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Emoji button
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFf0f4f8),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined, 
                    color: Color(0xFF4a5568), size: 22),
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _showEmojiPicker = !_showEmojiPicker;
                    if (_showEmojiPicker) {
                      _focusNode.unfocus();
                    } else {
                      _focusNode.requestFocus();
                    }
                  });
                },
              ),
            ),
            // Message input field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFf0f4f8),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        maxLines: 4,
                        minLines: 1,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2d3748),
                          fontSize: 15.0,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.poppins(
                            color: const Color(0xFFa0aec0),
                            fontSize: 15.0,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            _sendMessage(text);
                            _messageController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Send button
                    GestureDetector(
                      onTap: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          _sendMessage(_messageController.text);
                          _messageController.clear();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          gradient: _messageController.text.trim().isNotEmpty
                              ? const LinearGradient(
                                  colors: [Color(0xFF20c997), Color(0xFF12b0ff)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _messageController.text.trim().isNotEmpty
                              ? null
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                          boxShadow: _messageController.text.trim().isNotEmpty
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF20c997).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.send,
                          color: _messageController.text.trim().isNotEmpty
                              ? Colors.white
                              : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}

class Message with ChangeNotifier {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
