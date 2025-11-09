import 'package:flutter/material.dart';
import '../../services/wellness_service.dart';

class BreathingExercisesScreen extends StatefulWidget {
  @override
  _BreathingExercisesScreenState createState() => _BreathingExercisesScreenState();
}

class _BreathingExercisesScreenState extends State<BreathingExercisesScreen> {
  final WellnessService _wellnessService = WellnessService();
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;

  // Search and filter variables
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Duration';
  final List<String> _categories = ['All', 'Stress Relief', 'Relaxation', 'Energy', 'Sleep'];
  final List<String> _sortOptions = ['Duration', 'Title', 'Popularity'];

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await _wellnessService.getBreathingExercises();
    setState(() {
      _exercises = exercises;
      _isLoading = false;
    });
  }

  // Filtered exercises based on search and filters
  List<Map<String, dynamic>> get _filteredExercises {
    var filtered = _exercises.where((exercise) {
      final matchesSearch = exercise['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           exercise['description'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || 
                             exercise['type'] == _selectedCategory;
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

  void _startExercise(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    exercise['type'],
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: blueColor,
                ),
                SizedBox(width: 8),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${exercise['popularity']}'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Steps:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...exercise['steps'].map<Widget>((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text('• $step'),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start the exercise timer here
            },
            child: Text('Start ${exercise['duration']}min'),
          ),
        ],
      ),
    );
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
                    hintText: 'Search breathing exercises...',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Breathing Exercises',
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
                    'Loading breathing exercises...',
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
                  child: _filteredExercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: grayColor),
                              SizedBox(height: 16),
                              Text(
                                'No exercises found',
                                style: TextStyle(fontSize: 18, color: grayColor),
                              ),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(color: grayColor),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            return Card(
                              elevation: 3,
                              color: whiteColor,
                              margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: lightGreenColor.withOpacity(0.1),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: lightGreenColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  exercise['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise['description'],
                                      style: TextStyle(color: grayColor),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            exercise['type'],
                                            style: TextStyle(fontSize: 10, color: Colors.white),
                                          ),
                                          backgroundColor: blueColor.withOpacity(0.8),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.star, color: Colors.amber, size: 14),
                                        Text(
                                          ' ${exercise['popularity']}',
                                          style: TextStyle(fontSize: 12, color: grayColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Chip(
                                  label: Text(
                                    '${exercise['duration']} min',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: blueColor,
                                ),
                                onTap: () => _startExercise(exercise),
                                contentPadding: EdgeInsets.all(16),
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