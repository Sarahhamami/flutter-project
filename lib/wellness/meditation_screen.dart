import 'package:flutter/material.dart';
import '../../services/wellness_service.dart';

class MeditationScreen extends StatefulWidget {
  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final WellnessService _wellnessService = WellnessService();
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  // Search and filter variables
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Duration';
  final List<String> _categories = ['All', 'Energy', 'Relaxation', 'Sleep', 'Stress Relief', 'Focus'];
  final List<String> _sortOptions = ['Duration', 'Title', 'Popularity'];

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _wellnessService.getMeditationSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  // Filtered sessions based on search and filters
  List<Map<String, dynamic>> get _filteredSessions {
    var filtered = _sessions.where((session) {
      final matchesSearch = session['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           session['description'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || 
                             session['type'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Sort based on selected option
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Title':
          return a['title'].compareTo(b['title']);
        case 'Popularity':
          return (b['popularity'] ?? 0).compareTo(a['popularity'] ?? 0);
        case 'Duration':
        default:
          return a['duration'].compareTo(b['duration']);
      }
    });

    return filtered;
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search bar
        Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: grayColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: grayColor),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search meditation sessions...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: grayColor),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, size: 20, color: grayColor),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
            ],
          ),
        ),

        // Filters and sort
        Row(
          children: [
            // Category filter
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: grayColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: Icon(Icons.filter_list, color: blueColor, size: 20),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            
            // Sort
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: grayColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  icon: Icon(Icons.sort, color: blueColor, size: 20),
                  items: _sortOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sortBy = newValue!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _startMeditation(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session['description'] ?? 'Guided meditation session',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(
                    session['type'],
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: blueColor,
                ),
                SizedBox(width: 8),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${session['popularity']}'),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Duration: ${session['duration']} minutes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: grayColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start meditation session here
            },
            child: Text('Start Meditation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Guided Meditation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blueColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: blueColor),
                  SizedBox(height: 16),
                  Text(
                    'Loading meditation sessions...',
                    style: TextStyle(color: grayColor),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: _buildSearchAndFilters(),
                ),
                Expanded(
                  child: _filteredSessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: grayColor),
                              SizedBox(height: 16),
                              Text(
                                'No sessions found',
                                style: TextStyle(fontSize: 18, color: grayColor),
                              ),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(color: grayColor),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _filteredSessions.length,
                          itemBuilder: (context, index) {
                            final session = _filteredSessions[index];
                            return Card(
                              elevation: 3,
                              color: whiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _startMeditation(session),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.self_improvement_rounded,
                                        size: 40,
                                        color: lightGreenColor,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        session['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        session['type'],
                                        style: TextStyle(
                                          color: grayColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 14),
                                          Text(
                                            ' ${session['popularity']}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Chip(
                                        label: Text(
                                          '${session['duration']} min',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                        backgroundColor: blueColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}