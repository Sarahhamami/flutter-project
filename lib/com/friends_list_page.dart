import 'package:flutter/material.dart';
import 'chat_conversation_page.dart';
import '../db/database_helper.dart';
import 'package:firebase_database/firebase_database.dart';

// Color palette
const Color kWhite = Colors.white;
const Color kPrimary = Color(0xFF01BCE5);
const Color kDark = Color(0xFF52575A);
const Color kAccent = Color(0xFF08CAC2);

// Friend/User Model
class Friend {
  final int userId;
  final String name;
  final String avatar;
  final String status; // online, offline, away
  String lastMessage;
  DateTime lastMessageTime;
  final bool hasUnread;
  final int unreadCount;

  Friend({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.status,
    required this.lastMessage,
    required this.lastMessageTime,
    this.hasUnread = false,
    this.unreadCount = 0,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    // Use real data from database, not random messages
    final fullName = '${map['prenom']} ${map['nom']}';
    final statuses = ['online', 'away', 'offline'];
    final randomStatus = statuses[map['user_id']! % 3];

    return Friend(
      userId: map['user_id'] as int,
      name: fullName,
      avatar: 'assets/images/splash.png',
      status: randomStatus,
      lastMessage: 'Start a conversation!', // Will be updated from Firebase
      lastMessageTime: DateTime.now(), // Will be updated from Firebase
      hasUnread: false, // Will be updated from Firebase
      unreadCount: 0, // Will be updated from Firebase
    );
  }
}

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Friend> _friends = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Friend> _filteredFriends = [];
  int? _currentUserId;

  // Static exclusion for testing - change this to exclude different users
  final int _excludedUserId = 2; // Exclude user with ID 2 (John Smith)

  Future<void> _loadCurrentUser() async {
    try {
      _currentUserId = await _dbHelper.getDefaultUserId();
      debugPrint('👤 FriendsListPage loaded current user ID: $_currentUserId');
      await _loadFriends();
      await _loadConversationsFromFirebase();
      _setupConversationListener();
    } catch (e) {
      debugPrint('❌ Error loading current user in FriendsListPage: $e');
      _currentUserId = 1; // Fallback
      await _loadFriends();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final users = await _dbHelper.getAllUsers();
      debugPrint('📊 Total users in database: ${users.length}');
      for (var user in users) {
        debugPrint('👤 User ID: ${user['user_id']}, Name: ${user['prenom']} ${user['nom']}, Email: ${user['email']}');
      }

      final friendsList = <Friend>[];
      for (var user in users) {
        // Exclude the specified user ID (static exclusion for testing)
        if (user['user_id'] != _excludedUserId) {
          debugPrint('➕ Adding friend: ${user['prenom']} ${user['nom']} (ID: ${user['user_id']})');
          friendsList.add(Friend.fromMap(user));
        } else {
          debugPrint('🚫 Excluding user: ${user['prenom']} ${user['nom']} (ID: ${user['user_id']}) - Static exclusion');
        }
      }

      setState(() {
        _friends = friendsList;
        _filteredFriends = _friends;
        _isLoading = false;
      });

      debugPrint('👥 FriendsListPage loaded ${_friends.length} friends (excluding user ID $_excludedUserId)');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchFriends(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFriends = _friends;
      } else {
        _filteredFriends = _friends.where((friend) {
          return friend.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _loadConversationsFromFirebase() async {
    if (_currentUserId == null) return;

    try {
      debugPrint('🔄 FriendsListPage loading conversations from Firebase for user $_currentUserId');
      final conversationsRef = FirebaseDatabase.instance
          .ref()
          .child('conversations');

      final snapshot = await conversationsRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        debugPrint('📊 FriendsListPage found ${data.length} conversations');

        // Update friends with real conversation data
        for (var friend in _friends) {
          final friendId = friend.userId;
          final conversationId = _getConversationId(_currentUserId!, friendId);

          if (data.containsKey(conversationId)) {
            final convData = data[conversationId] as Map;
            final lastMessage = convData['lastMessage'];
            final lastMessageTime = convData['lastMessageTime'];

            if (lastMessage != null && lastMessage.toString().isNotEmpty) {
              friend.lastMessage = lastMessage.toString();
              debugPrint('✅ FriendsListPage updated ${friend.name} with: "$lastMessage"');
            }

            if (lastMessageTime != null) {
              try {
                friend.lastMessageTime = DateTime.fromMillisecondsSinceEpoch(int.parse(lastMessageTime.toString()));
              } catch (e) {
                debugPrint('⚠️ Error parsing timestamp: $e');
              }
            }
          }
        }

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('❌ FriendsListPage error loading conversations: $e');
    }
  }

  void _setupConversationListener() {
    debugPrint('👂 FriendsListPage setting up conversation listener');
    FirebaseDatabase.instance
        .ref()
        .child('conversations')
        .onValue
        .listen((event) {
          debugPrint('📡 FriendsListPage conversations updated');
          if (_currentUserId != null && mounted) {
            _loadConversationsFromFirebase();
          }
        }, onError: (error) {
          debugPrint('❌ FriendsListPage conversation listener error: $error');
        });
  }

  String _getConversationId(int user1, int user2) {
    final sorted = [user1, user2]..sort();
    return 'conversation_${sorted[0]}_${sorted[1]}';
  }

  void _openChat(BuildContext context, Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationPage(friend: friend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: kWhite,
        foregroundColor: kDark,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: kPrimary),
              onPressed: _loadFriends,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  kPrimary.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search, color: kPrimary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: kDark.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: kPrimary, width: 2),
                ),
                filled: true,
                fillColor: kDark.withOpacity(0.05),
              ),
              onChanged: _searchFriends,
            ),
          ),
          // Friends list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : _filteredFriends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: kPrimary.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'No users yet' : 'No results found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: kDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Users from database will appear here'
                                  : 'Try a different search term',
                              style: TextStyle(
                                color: kDark.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFriends,
                        color: kPrimary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredFriends.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final friend = _filteredFriends[index];
                            return _FriendCard(
                              friend: friend,
                              onTap: () => _openChat(context, friend),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Friend friend;
  final VoidCallback onTap;

  const _FriendCard({required this.friend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kDark.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kDark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with online status
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: const AssetImage('assets/images/splash.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getStatusColor(friend.status),
                          border: Border.all(color: kWhite, width: 2),
                          shape: BoxShape.circle,
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
                        children: [
                          Expanded(
                            child: Text(
                              friend.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: kDark,
                              ),
                            ),
                          ),
                          if (friend.hasUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kPrimary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${friend.unreadCount}',
                                style: const TextStyle(
                                  color: kWhite,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friend.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kDark.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: friend.hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Time
                Column(
                  children: [
                    Text(
                      _formatTime(friend.lastMessageTime),
                      style: TextStyle(
                        color: kDark.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.chevron_right,
                      color: kDark.withOpacity(0.3),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
