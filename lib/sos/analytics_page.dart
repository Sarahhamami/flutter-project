import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../db/database_helper.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      // Get various statistics from the database
      final db = await _dbHelper.database;

      // Emergency contacts count
      final emergencyContacts = await db.rawQuery('SELECT COUNT(*) as count FROM EmergencyContact');
      final emergencyContactsCount = emergencyContacts.first['count'] as int;

      // Emergency alerts count
      final emergencyAlerts = await db.rawQuery('SELECT COUNT(*) as count FROM EmergencyAlert');
      final emergencyAlertsCount = emergencyAlerts.first['count'] as int;

      // First aid guides count
      final firstAidGuides = await db.rawQuery('SELECT COUNT(*) as count FROM FirstAidGuide');
      final firstAidGuidesCount = firstAidGuides.first['count'] as int;

      // Medical records count
      final medicalRecords = await db.rawQuery('SELECT COUNT(*) as count FROM UserMedicalRecord');
      final medicalRecordsCount = medicalRecords.first['count'] as int;

      // Medications count
      final medications = await db.rawQuery('SELECT COUNT(*) as count FROM Medication');
      final medicationsCount = medications.first['count'] as int;

      // Tasks statistics
      final tasksStats = await _dbHelper.getTaskStats(1); // Default user

      // Forum statistics
      final forumStats = await _dbHelper.getForumStats();

      setState(() {
        _stats = {
          'emergencyContacts': emergencyContactsCount,
          'emergencyAlerts': emergencyAlertsCount,
          'firstAidGuides': firstAidGuidesCount,
          'medicalRecords': medicalRecordsCount,
          'medications': medicationsCount,
          'tasks': tasksStats,
          'forum': forumStats,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Color(0xFF0DCAF0),
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [

              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.05),
              Colors.blue.withOpacity(0.05),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.1),
                                Colors.blue.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.analytics,
                                      color: Colors.purple,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Analytics Dashboard',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Comprehensive health data insights',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
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

                        const SizedBox(height: 32),

                        // Emergency Section
                        _buildSectionHeader('Emergency Services', Icons.emergency, Colors.red),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Emergency Contacts',
                                _stats['emergencyContacts']?.toString() ?? '0',
                                Icons.contacts,
                                Colors.red,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                'Emergency Alerts',
                                _stats['emergencyAlerts']?.toString() ?? '0',
                                Icons.warning,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Medical Data Section
                        _buildSectionHeader('Medical Data', Icons.medical_services, AppColors.lightGreen),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'First Aid Guides',
                                _stats['firstAidGuides']?.toString() ?? '0',
                                Icons.medical_services,
                                AppColors.lightGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                'Medical Records',
                                _stats['medicalRecords']?.toString() ?? '0',
                                Icons.folder_shared,
                                AppColors.blue,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _buildMetricCard(
                          'Medications',
                          _stats['medications']?.toString() ?? '0',
                          Icons.medication,
                          Colors.orange,
                          isFullWidth: true,
                        ),

                        const SizedBox(height: 32),

                        // Tasks Section
                        _buildSectionHeader('Task Management', Icons.task, Colors.teal),
                        const SizedBox(height: 16),
                        if (_stats['tasks'] != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  'Total Tasks',
                                  _stats['tasks']['total']?.toString() ?? '0',
                                  Icons.list,
                                  Colors.teal,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildMetricCard(
                                  'Completed',
                                  _stats['tasks']['completed']?.toString() ?? '0',
                                  Icons.check_circle,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  'Pending',
                                  _stats['tasks']['pending']?.toString() ?? '0',
                                  Icons.pending,
                                  Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildMetricCard(
                                  'Overdue',
                                  _stats['tasks']['overdue']?.toString() ?? '0',
                                  Icons.warning,
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Forum Section
                        _buildSectionHeader('Community Forum', Icons.forum, Colors.indigo),
                        const SizedBox(height: 16),
                        if (_stats['forum'] != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  'Forum Topics',
                                  _stats['forum']['topics']?.toString() ?? '0',
                                  Icons.topic,
                                  Colors.indigo,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildMetricCard(
                                  'Forum Posts',
                                  _stats['forum']['posts']?.toString() ?? '0',
                                  Icons.comment,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildMetricCard(
                            'Active Users',
                            _stats['forum']['users']?.toString() ?? '0',
                            Icons.people,
                            Colors.purple,
                            isFullWidth: true,
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Refresh Button
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _loadAnalytics,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}