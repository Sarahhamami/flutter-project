import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/actPhy/activit%C3%A9/activit%C3%A9.dart';
import 'package:flutter_application_1/actPhy/activit%C3%A9/badges.dart';
import 'package:flutter_application_1/actPhy/activit%C3%A9/chatFitness.dart';
import 'package:flutter_application_1/actPhy/activit%C3%A9/historyA.dart';
import 'package:flutter_application_1/actPhy/activit%C3%A9/newActivity.dart';
import 'package:flutter_application_1/actPhy/activit%C3%A9/videos.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../com/articles_display.dart';
import '../../db/database_helper.dart';

// Activity model to map database results
class Activity {
  final int id;
  final int userId;
  final String type;
  final DateTime date;
  final int? duration;
  final double? distance;
  final double? caloriesBurned;

  Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    this.duration,
    this.distance,
    this.caloriesBurned,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id_activite'],
      userId: map['id_utilisateur'],
      type: map['type_activite'],
      date: DateTime.parse(map['date_activite']),
      duration: map['duree'],
      distance: map['distance']?.toDouble(),
      caloriesBurned: map['calories_brulees']?.toDouble(),
    );
  }
}

class AccueilAP extends StatefulWidget {
  const AccueilAP({Key? key}) : super(key: key);

  @override
  _AccueilAPState createState() => _AccueilAPState();
}

class _AccueilAPState extends State<AccueilAP> with TickerProviderStateMixin {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isExpanded = false;
  bool _showBarChart = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Database helper
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // Activity data
  List<Activity> _activities = [];
  Map<DateTime, List<Activity>> _activitiesByDate = {};
  Map<String, int> _activityCounts = {};
  Map<String, Color> _activityColors = {
    'Walking/Running': Colors.green,
    'Cycling': Colors.blue,
    'Swimming': Colors.cyan,
    'Weightlifting': Colors.orange,
    'Yoga': Colors.purple,
  };

  @override
  void initState() {

    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Load activities when the widget initializes
    _loadActivities();
  }

  // Load activities from database
  Future<void> _loadActivities() async {
    try {
      
        final db = await _databaseHelper.database;

        // Get the user ID from DatabaseHelper
        final dbHelper = DatabaseHelper();
        int userId = await dbHelper.getDefaultUserId();
      final List<Map<String, dynamic>> maps = await db.query(
        'Activite_physique',
        where: 'id_utilisateur = ?',
        whereArgs: [userId], // Assuming user ID 1 for now
      );

      setState(() {
        _activities = maps.map((map) => Activity.fromMap(map)).toList();
        
        // Group activities by date
        _activitiesByDate = {};
        for (var activity in _activities) {
          final date = DateTime(activity.date.year, activity.date.month, activity.date.day);
          if (_activitiesByDate[date] == null) {
            _activitiesByDate[date] = [];
          }
          _activitiesByDate[date]!.add(activity);
        }
        
        // Count activities by type for the chart
        _activityCounts = {};
        for (var activity in _activities) {
          _activityCounts[activity.type] = (_activityCounts[activity.type] ?? 0) + 1;
        }
      });
    } catch (e) {
      print('Error loading activities: $e');
    }
  }

  // Get activities for a specific day
  List<Activity> _getActivitiesForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _activitiesByDate[date] ?? [];
  }

  // Get events for the calendar
  List<dynamic> _getEventsForDay(DateTime day) {
    return _getActivitiesForDay(day).map((activity) => activity.type).toList();
  }

  // Get marker for calendar
  Widget _buildEventMarker(DateTime date) {
    final events = _getEventsForDay(date);
    if (events.isEmpty) return Container();
    
    return Positioned(
      right: 1,
      top: 1,
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _activityColors[events.first] ?? Colors.blue,
          shape: BoxShape.circle,
        ),
        width: 6,
        height: 6,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ArticlesDisplay()),
          ),
        ),
        title: const Text('Fitness'),
        backgroundColor: const Color(0xFF20c997),
      ),
      backgroundColor: const Color(0xFF20c997).withOpacity(0.7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with Calendar
              _buildCalendarSection(),
              
              // Navigation Buttons
              _buildNavigationButtons(),
              
              // Charts Section
              _buildChartsSection(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TableCalendar<dynamic>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF20c997)),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFF20c997)),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Color(0xFF20c997),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF20c997),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: Colors.white),
              selectedTextStyle: const TextStyle(color: Colors.white),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSameDay(date, DateTime.now())
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    _buildEventMarker(date),
                  ],
                );
              },
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          if (!_isExpanded)
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF20c997)),
              onPressed: _toggleExpand,
            ),
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _getActivitiesForDay(_selectedDay).isEmpty
                  ? const Text(
                      'No activities for this day',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activities for ${DateFormat('MMMM d, y').format(_selectedDay)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._getActivitiesForDay(_selectedDay).map((activity) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _activityColors[activity.type] ?? Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${activity.type} - ${activity.duration} min',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (activity.distance != null)
                                Text(
                                  '${activity.distance} km',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNavigationButtons() {

final List<Map<String, dynamic>> buttons = [
  {
    'icon': Icons.history,
    'label': 'History',
    'onTap': (BuildContext context) async {
      final dbHelper = DatabaseHelper();
      int userId = await dbHelper.getDefaultUserId(); // get the user ID
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivityHistoryPage(userId: userId),
        ),
      );
        // reload when returning from the page
    },
  },
 {
  'icon': Icons.add_circle_outline,
  'label': 'New Activity',
  'onTap': (BuildContext context) async {
    // Navigate to NewActivityPage and wait until the page is popped
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewActivityPage()),
    );

    // After returning, reload activities
    // Make sure _loadActivities() is accessible here
    _loadActivities();
  },
},

  {
    'icon': Icons.directions_run,
    'label': 'Activities',
    'onTap': (BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActivityCategoriesPage()),
    ),
  },
  {
    'icon': Icons.emoji_events_outlined,
    'label': 'Badges',
    'onTap': (BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BadgesPage()),
    ),
  },
  {
    'icon': Icons.ondemand_video,
    'label': 'Videos',
    'onTap': (BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideosScreen()),
    ),
  },
  {
    'icon': Icons.smart_toy_outlined,
    'label': 'Hamma Coach',
    'onTap': (BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatFitness()),
    ),
  },
];


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: buttons.length,
        itemBuilder: (context, index) {
          // Return empty container for the placeholder
          if (buttons[index]['icon'] == null) {
            return Container();
          }
          return _buildNavigationButton(
            icon: buttons[index]['icon'] as IconData,
            label: buttons[index]['label'] as String,
            onTap: () => buttons[index]['onTap'](context),
          );
        },
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF20c997)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overview',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Bar Chart',
                    style: GoogleFonts.poppins(
                      color: _showBarChart ? const Color(0xFF20c997) : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: _showBarChart,
                    onChanged: (value) {
                      setState(() {
                        _showBarChart = value;
                      });
                    },
                    activeColor: const Color(0xFF20c997),
                  ),
                  Text(
                    'Pie Chart',
                    style: GoogleFonts.poppins(
                      color: !_showBarChart ? const Color(0xFF20c997) : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: _showBarChart ? _buildBarChart() : _buildPieChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final activityTypes = _activityCounts.keys.toList();
    
    if (activityTypes.isEmpty) {
      return Center(
        child: Text(
          'No activity data available',
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      );
    }
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _activityCounts.values.isNotEmpty 
            ? _activityCounts.values.reduce(max).toDouble() + 1 
            : 1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.white,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final type = activityTypes[groupIndex];
              return BarTooltipItem(
                '${_activityCounts[type] ?? 0} ${type}',
                GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= activityTypes.length) return Container();
                final type = activityTypes[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    type.split(' ').map((s) => s[0]).join(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[200],
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: activityTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (_activityCounts[type] ?? 0).toDouble(),
                color: _activityColors[type] ?? Colors.blue,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_activityCounts.isEmpty) {
      return Center(
        child: Text(
          'No activity data available',
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      );
    }
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: _activityCounts.entries.map((entry) {
          final type = entry.key;
          final count = entry.value;
          final total = _activityCounts.values.reduce((a, b) => a + b);
          final percentage = (count / total * 100).round();
          
          return PieChartSectionData(
            color: _activityColors[type] ?? Colors.blue,
            value: count.toDouble(),
            title: '$percentage%',
            titleStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            radius: 80,
          );
        }).toList(),
      ),
    );
  }
}