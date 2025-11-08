import 'package:flutter/material.dart';
import 'chat_conversation_page.dart';
import '../db/database_helper.dart';
import '../models/article.dart';
import 'package:firebase_database/firebase_database.dart';
import 'navbar.dart';
import 'articles_display.dart';
import 'forum_page.dart';

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
    // Create User instance first
    final user = User.fromMap(map);
    final statuses = ['online', 'away', 'offline'];
    final randomStatus = statuses[map['user_id']! % 3];

    return Friend(
      userId: user.userId,
      name: user.fullName,
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
  int _selectedIndex = 2; // Start with chat selected

  // Dynamic exclusion based on current user
  int? _excludedUserId; // Will be set to current user ID

  Future<void> _loadCurrentUser() async {
    try {
      _currentUserId = await _dbHelper.getDefaultUserId();
      _excludedUserId = _currentUserId; // Exclude current user from friends list
      debugPrint('👤 FriendsListPage loaded current user ID: $_currentUserId');
      await _loadFriends();
      await _loadConversationsFromFirebase();
      _setupConversationListener();
    } catch (e) {
      debugPrint('❌ Error loading current user in FriendsListPage: $e');
      _currentUserId = 1; // Fallback
      _excludedUserId = _currentUserId; // Exclude current user from friends list
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
        // Exclude the current user from friends list
        if (user['user_id'] != _excludedUserId) {
          debugPrint('➕ Adding friend: ${user['prenom']} ${user['nom']} (ID: ${user['user_id']})');
          friendsList.add(Friend.fromMap(user));
        } else {
          debugPrint('🚫 Excluding user: ${user['prenom']} ${user['nom']} (ID: ${user['user_id']}) - Current user');
        }
      }

      setState(() {
        _friends = friendsList;
        _filteredFriends = _friends;
        _isLoading = false;
      });

      debugPrint('👥 FriendsListPage loaded ${_friends.length} friends (excluding current user ID $_excludedUserId)');
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation for different tabs
    switch (index) {
      case 0: // Home - navigate to articles display
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ArticlesDisplay()),
        );
        break;
      case 1: // Search
        // Add search functionality here if needed
        break;
      case 2: // Chat - already here
        break;
      case 3: // Forum
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ForumPage()),
        );
        break;
      case 4: // Profile
        // Add profile functionality here if needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
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
        automaticallyImplyLeading: false, // Remove back arrow
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
          // Amazing Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPrimary.withOpacity(0.1),
                  kAccent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: kPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '💬 Chat Hub',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connect & Chat',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: kDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stay connected with your friends and community',
                            style: TextStyle(
                              color: kDark.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/splash.png'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Enhanced Search bar
                Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: kDark.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search conversations...',
                      hintStyle: TextStyle(color: kDark.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search, color: kPrimary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: kDark.withOpacity(0.5)),
                              onPressed: () {
                                _searchController.clear();
                                _searchFriends('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    onChanged: _searchFriends,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
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
                              _searchQuery.isEmpty ? 'No conversations yet' : 'No results found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: kDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Start chatting with friends and community members'
                                  : 'Try a different search term',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kDark.withOpacity(0.7),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFriends,
                        color: kPrimary,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredFriends.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kDark.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: kPrimary.withOpacity(0.03),
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
