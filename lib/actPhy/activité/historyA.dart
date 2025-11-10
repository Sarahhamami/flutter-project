import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../db/database_helper.dart';
import 'edit_activity.dart';

// Hide the path package's context to avoid conflicts
import 'package:path/path.dart' hide Context;

class ActivityHistoryPage extends StatefulWidget {
  final int userId;

  const ActivityHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ActivityHistoryPageState createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> activities = await db.query(
        'Activite_physique',
        where: 'id_utilisateur = ?',
        whereArgs: [widget.userId],
        orderBy: 'date_activite DESC',
      );

      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading activities: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final currentContext = this.context; // Capture BuildContext
        if (currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(content: Text('Failed to load activities')),
          );
        }
      }
    }
  }

  Future<void> _deleteActivity(int id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'Activite_physique',
        where: 'id_activite = ?',
        whereArgs: [id],
      );
      _loadActivities(); // Refresh the list
      if (mounted) {
        final currentContext = this.context; // Capture BuildContext
        if (currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(content: Text('Activity deleted')),
          );
        }
      }
    } catch (e) {
      print('Error deleting activity: $e');
      if (mounted) {
        final currentContext = this.context; // Capture BuildContext
        if (currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(content: Text('Failed to delete activity')),
          );
        }
      }
    }
  }

  void _showActivityDetails(Map<String, dynamic> activity) {
    // Get the BuildContext from the widget's context
    final BuildContext currentContext = this.context;
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: currentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => ActivityDetailsSheet(
        activity: activity,
        onDelete: () {
          Navigator.pop(sheetContext);
          _deleteActivity(activity['id_activite']);
        },
        onUpdate: _loadActivities,
      ),
    );
  }

  Widget _buildActivityIcon(String activityType) {
    final iconData = {
      'Walking/Running': Icons.directions_walk,
      'Cycling': Icons.directions_bike,
      'Swimming': Icons.pool,
      'Weightlifting': Icons.fitness_center,
    }[activityType] ?? Icons.directions_run;

    final color = {
      'Walking/Running': const Color(0xFF0dcaf0),
      'Cycling': const Color(0xFF20c997),
      'Swimming': const Color(0xFF17a2b8),
      'Weightlifting': const Color(0xFF6f42c1),
    }[activityType] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No activities yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start tracking your activities to see them here',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    final date = DateTime.parse(activity['date_activite']);
                    final formattedDate = DateFormat('MMM d, y').format(date);
                    final duration = activity['duree'] != null
                        ? '${activity['duree']} min'
                        : 'N/A';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => _showActivityDetails(activity),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _buildActivityIcon(activity['type_activite']),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity['type_activite'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                duration,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF20c997),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class ActivityDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const ActivityDetailsSheet({
    Key? key,
    required this.activity,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String type = activity['type_activite'] ?? 'Unknown';
    final String formattedDate = activity['date_activite'] != null
        ? DateFormat('MMM d, y - hh:mm a').format(
            DateTime.parse(activity['date_activite']).toLocal(),
          )
        : 'No date';
    final String duration = '${activity['duree'] ?? 0} min';
    final String distance = '${activity['distance'] ?? 0} km';
    final String steps = activity['pas']?.toString() ?? '0';
    final String calories = '${activity['calories_brulees'] ?? 0} kcal';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getActivityColor(activity['type_activite']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getActivityIcon(activity['type_activite']),
                  color: _getActivityColor(activity['type_activite']),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                activity['type_activite'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(Icons.calendar_today, 'Date', formattedDate),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.timer, 'Duration', duration),
          if (activity['distance'] != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(Icons.directions_walk, 'Distance', distance),
          ],
          if (activity['pas'] != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(Icons.directions_run, 'Steps', steps),
          ],
          const SizedBox(height: 16),
          _buildDetailRow(Icons.local_fire_department, 'Calories', calories),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implement edit functionality
                    Navigator.pop(context); // Close the bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditActivityPage(
                          activity: activity,
                          onUpdate: onUpdate,
                        ),
                      ),
                    ).then((_) => onUpdate());
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFF0dcaf0)),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Color(0xFF0dcaf0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Delete Activity'),
                        content: const Text('Are you sure you want to delete this activity?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              onDelete();
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('DELETE'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static IconData _getActivityIcon(String activityType) {
    return {
      'Walking/Running': Icons.directions_walk,
      'Cycling': Icons.directions_bike,
      'Swimming': Icons.pool,
      'Weightlifting': Icons.fitness_center,
    }[activityType] ?? Icons.directions_run;
  }

  static Color _getActivityColor(String activityType) {
    return {
      'Walking/Running': const Color(0xFF0dcaf0),
      'Cycling': const Color(0xFF20c997),
      'Swimming': const Color(0xFF17a2b8),
      'Weightlifting': const Color(0xFF6f42c1),
    }[activityType] ?? Colors.grey;
  }
}