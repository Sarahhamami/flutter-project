import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/article.dart';
import 'forum_comments_page.dart';

// Color palette for better UI
const Color kPrimary = Color(0xFF01BCE5);
const Color kAccent = Color(0xFF08CAC2);
const Color kDark = Color(0xFF52575A);
const Color kLightGrey = Color(0xFFF8F9FA);
const Color kCardShadow = Color(0x0D000000);

// Forum Topic Model (matches database schema)
class ForumTopic {
  final int? topicId;
  final String title;
  final String description;
  final int createdBy;
  final String createdAt;
  final User? author;
  final int commentCount;
  final String? firstComment;
  final String? firstCommentAuthor;
  final int likeCount;
  final bool isLikedByCurrentUser;

  ForumTopic({
    this.topicId,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    this.author,
    this.commentCount = 0,
    this.firstComment,
    this.firstCommentAuthor,
    this.likeCount = 0,
    this.isLikedByCurrentUser = false,
  });

  factory ForumTopic.fromMap(Map<String, dynamic> map) {
    User? author;
    if (map['user_id'] != null) {
      author = User.fromMap(map);
    }

    return ForumTopic(
      topicId: map['topic_id'],
      title: map['title'],
      description: map['description'],
      createdBy: map['created_by'],
      createdAt: map['created_at'],
      author: author,
      commentCount: map['comment_count'] ?? 0,
      firstComment: map['first_comment'],
      firstCommentAuthor: map['first_comment_author'],
      likeCount: map['like_count'] ?? 0,
      isLikedByCurrentUser: map['is_liked_by_current_user'] == 1,
    );
  }
}

// Legacy Forum Post Model (keeping for backward compatibility)
class ForumPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorAvatar;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final List<String> tags;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorAvatar,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.tags,
  });
}

// Sample forum posts data
List<ForumPost> samplePosts = [
  ForumPost(
    id: '1',
    title: 'Best practices for maintaining a healthy lifestyle',
    content: 'I\'ve been following a healthy routine for the past 6 months and wanted to share some tips that have worked really well for me...',
    author: 'Sarah Johnson',
    authorAvatar: 'assets/images/splash.png',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    likes: 24,
    comments: 8,
    tags: ['Health', 'Lifestyle', 'Tips'],
  ),
  ForumPost(
    id: '2',
    title: 'Dealing with anxiety during health checkups',
    content: 'Does anyone else get really anxious before doctor appointments? I\'d love to hear how you cope with this...',
    author: 'Mike Chen',
    authorAvatar: 'assets/images/splash.png',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    likes: 18,
    comments: 12,
    tags: ['Mental Health', 'Anxiety', 'Support'],
  ),
  ForumPost(
    id: '3',
    title: 'New study on Mediterranean diet benefits',
    content: 'Just read this interesting article about how the Mediterranean diet can reduce cardiovascular risks. Anyone tried it?',
    author: 'Emily Rodriguez',
    authorAvatar: 'assets/images/splash.png',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    likes: 31,
    comments: 15,
    tags: ['Nutrition', 'Research', 'Diet'],
  ),
  ForumPost(
    id: '4',
    title: 'Morning workout routine recommendations',
    content: 'Looking for a good 30-minute morning workout that I can do at home. Any suggestions?',
    author: 'David Kim',
    authorAvatar: 'assets/images/splash.png',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    likes: 12,
    comments: 6,
    tags: ['Exercise', 'Workout', 'Morning'],
  ),
];

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _selectedFilter = 'All';
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  List<ForumTopic> _forumTopics = [];
  List<ForumTopic> _filteredTopics = [];
  bool _isLoading = true;
  int _currentUserId = 1; // Will be updated with actual user ID
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
    _initializeForum();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeForum() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get the default user ID
      _currentUserId = await _dbHelper.getDefaultUserId();
      
      // Clear any existing sample topics for a clean start
      // await _dbHelper.clearSampleTopics(); // Commented out to preserve data between app runs
      
      // Load forum topics (only user-created ones)
      await _loadForumTopics();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing forum: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadForumTopics() async {
    try {
      final topics = await _dbHelper.getAllForumTopics();
      setState(() {
        _forumTopics = topics.map((topic) => ForumTopic.fromMap(topic)).toList();
        _filteredTopics = _forumTopics;
        _isLoading = false;
      });
      
      // Debug print to see what we're getting
      print('Loaded ${_forumTopics.length} forum topics');
      for (var topic in _forumTopics) {
        print('Topic: ${topic.title} by ${topic.author?.fullName ?? 'Unknown'}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading topics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchTopics(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTopics = _forumTopics;
      } else {
        _filteredTopics = _forumTopics.where((topic) {
          return topic.title.toLowerCase().contains(query.toLowerCase()) ||
                 topic.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
      appBar: AppBar(
        title: const Text(
          'Health Forum',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: kDark,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (_searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.clear, color: Colors.red),
                onPressed: () {
                  _searchController.clear();
                  _searchTopics('');
                },
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _searchQuery.isNotEmpty 
                  ? kPrimary.withOpacity(0.2)
                  : kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : Icons.search, 
                color: kPrimary
              ),
              onPressed: () {
                _showSearchDialog();
              },
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
          // Welcome header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary.withOpacity(0.1), kAccent.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.forum_outlined,
                    color: kPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _searchQuery.isEmpty 
                            ? 'Welcome to Health Forum'
                            : 'Search Results',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _searchQuery.isEmpty 
                            ? 'Share your health journey and connect with others'
                            : '${_filteredTopics.length} topics found for "${_searchQuery}"',
                        style: TextStyle(
                          color: kDark.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Health', 'Nutrition', 'Exercise', 'Mental Health']
                    .map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: FilterChip(
                              label: Text(
                                filter,
                                style: TextStyle(
                                  fontWeight: _selectedFilter == filter 
                                      ? FontWeight.w600 
                                      : FontWeight.w500,
                                  color: _selectedFilter == filter 
                                      ? Colors.white 
                                      : kDark,
                                ),
                              ),
                              selected: _selectedFilter == filter,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: kPrimary,
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                color: _selectedFilter == filter 
                                    ? kPrimary 
                                    : kPrimary.withOpacity(0.3),
                                width: 1.5,
                              ),
                              elevation: _selectedFilter == filter ? 2 : 0,
                              shadowColor: kPrimary.withOpacity(0.3),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          
          // Posts list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: kPrimary,
                      strokeWidth: 3,
                    ),
                  )
                : _filteredTopics.isEmpty
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
                                Icons.forum_outlined,
                                size: 48,
                                color: kPrimary.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'No topics yet' : 'No results found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: kDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'Be the first to start a discussion!' 
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
                        onRefresh: _loadForumTopics,
                        color: kPrimary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTopics.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final topic = _filteredTopics[index];
                            return _ForumTopicCard(
                              topic: topic,
                              onDelete: () => _deleteTopic(topic),
                              onEdit: () => _loadForumTopics(),
                              onLikeToggle: () => _loadForumTopics(),
                              currentUserId: _currentUserId,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            _showCreatePostDialog();
          },
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'New Post',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.search,
                color: kPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Search Forum',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by title or description...',
            prefixIcon: Icon(Icons.search, color: kPrimary.withOpacity(0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimary, width: 2),
            ),
            filled: true,
            fillColor: kLightGrey,
          ),
          onChanged: (value) {
            _searchTopics(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: kDark.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _searchTopics(_searchController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Create New Post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'What\'s your post about?',
                  prefixIcon: Icon(Icons.title, color: kPrimary.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: kLightGrey,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts and experiences...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.message, color: kPrimary.withOpacity(0.7)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: kLightGrey,
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: kDark.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please fill in both title and content'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                print('Creating topic with user ID: $_currentUserId');
                final topicId = await _dbHelper.createForumTopic(
                  title: titleController.text.trim(),
                  description: contentController.text.trim(),
                  createdBy: _currentUserId,
                );
                print('Topic created with ID: $topicId');
                
                Navigator.pop(context);
                await _loadForumTopics(); // Refresh the list
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Topic created successfully!'),
                        ],
                      ),
                      backgroundColor: kAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating topic: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Create Post'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTopic(ForumTopic topic) async {
    try {
      await _dbHelper.deleteForumTopic(topic.topicId!);
      await _loadForumTopics(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Topic deleted successfully'),
              ],
            ),
            backgroundColor: kAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting topic: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ForumTopicCard extends StatefulWidget {
  final ForumTopic topic;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onLikeToggle;
  final int currentUserId;

  const _ForumTopicCard({
    required this.topic,
    required this.onDelete,
    required this.onEdit,
    required this.onLikeToggle,
    required this.currentUserId,
  });

  @override
  State<_ForumTopicCard> createState() => _ForumTopicCardState();
}

class _ForumTopicCardState extends State<_ForumTopicCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kCardShadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: kPrimary.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: kPrimary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [kPrimary.withOpacity(0.2), kAccent.withOpacity(0.2)],
                        ),
                        border: Border.all(
                          color: kPrimary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          widget.topic.author?.fullName.isNotEmpty == true
                              ? widget.topic.author!.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.topic.author?.fullName ?? 'Unknown User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: kDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimestamp(DateTime.parse(widget.topic.createdAt)),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.topic.createdBy == widget.currentUserId)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog();
                          } else if (value == 'delete') {
                            _showDeleteDialog();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: kPrimary, size: 16),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: kPrimary)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 16),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.more_vert,
                            color: kPrimary,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Topic title
                Text(
                  widget.topic.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: kDark,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Topic description
                Text(
                  widget.topic.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Divider
                Container(
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
                
                const SizedBox(height: 12),

                // Actions
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: kPrimary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Like button
                      Expanded(
                        child: _LikeButton(
                          isLiked: widget.topic.isLikedByCurrentUser,
                          likeCount: widget.topic.likeCount,
                          onTap: () async {
                            try {
                              final dbHelper = DatabaseHelper();
                              if (widget.topic.isLikedByCurrentUser) {
                                await dbHelper.removeForumLike(
                                  topicId: widget.topic.topicId!,
                                  userId: widget.currentUserId,
                                );
                              } else {
                                await dbHelper.addForumLike(
                                  topicId: widget.topic.topicId!,
                                  userId: widget.currentUserId,
                                );
                              }
                              widget.onLikeToggle();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error updating like: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      // Comment button
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.chat_bubble_outline,
                          label: widget.topic.commentCount > 0 ? '${widget.topic.commentCount}' : 'Comment',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForumCommentsPage(
                                  topicId: widget.topic.topicId!,
                                  topicTitle: widget.topic.title,
                                  topicDescription: widget.topic.description,
                                ),
                              ),
                            );
                          },
                        ),
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

  void _showEditDialog() {
    final titleController = TextEditingController(text: widget.topic.title);
    final contentController = TextEditingController(text: widget.topic.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Edit Post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'What\'s your post about?',
                  prefixIcon: Icon(Icons.title, color: kPrimary.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: kLightGrey,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts and experiences...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.message, color: kPrimary.withOpacity(0.7)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: kLightGrey,
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: kDark.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please fill in both title and content'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                final dbHelper = DatabaseHelper();
                await dbHelper.updateForumTopic(
                  topicId: widget.topic.topicId!,
                  title: titleController.text.trim(),
                  description: contentController.text.trim(),
                );

                Navigator.pop(context);

                widget.onEdit();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Topic updated successfully!'),
                        ],
                      ),
                      backgroundColor: kAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating topic: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Delete Topic'),
          ],
        ),
        content: Text('Are you sure you want to delete "${widget.topic.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _ForumPostCard extends StatefulWidget {
  final ForumPost post;
  
  const _ForumPostCard({required this.post});

  @override
  State<_ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<_ForumPostCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kCardShadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: kPrimary.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: kPrimary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [kPrimary.withOpacity(0.2), kAccent.withOpacity(0.2)],
                        ),
                        border: Border.all(
                          color: kPrimary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(widget.post.authorAvatar),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.author,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: kDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimestamp(widget.post.timestamp),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 12,
                            color: kPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hot',
                            style: TextStyle(
                              color: kPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Post title
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: kDark,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Post content
                Text(
                  widget.post.content,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.post.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimary.withOpacity(0.1), kAccent.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kPrimary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: kPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Divider
                Container(
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
                
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  children: [
                    _ActionButton(
                      icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                      label: '${widget.post.likes + (_isLiked ? 1 : 0)}',
                      onTap: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                      },
                      isLiked: _isLiked,
                    ),
                    const SizedBox(width: 20),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: '${widget.post.comments}',
                      onTap: () {},
                    ),
                    const SizedBox(width: 20),
                    _ActionButton(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: () {},
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 12,
                            color: kAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(widget.post.likes * 2.3).round()}',
                            style: TextStyle(
                              color: kAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLiked;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isLiked ? kPrimary : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isLiked ? kPrimary : Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: isLiked ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onTap;

  const _LikeButton({
    required this.isLiked,
    required this.likeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isLiked ? kPrimary : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                likeCount > 0 ? '$likeCount' : 'Like',
                style: TextStyle(
                  color: isLiked ? kPrimary : Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: isLiked ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
