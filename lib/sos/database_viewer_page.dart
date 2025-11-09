import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../db/database_helper.dart';
import 'database_seeder.dart';

class DatabaseViewerPage extends StatefulWidget {
  const DatabaseViewerPage({super.key});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final DatabaseSeeder _seeder = DatabaseSeeder();
  Map<String, List<Map<String, dynamic>>> _data = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = await _dbHelper.database;
      int userId = await _dbHelper.getDefaultUserId();

      // Charger les données de toutes les tables
      final medicalRecord = await _dbHelper.getUserMedicalRecord(userId);
      
      _data = {
        'EmergencyContact': await _dbHelper.getEmergencyContactsByUser(userId),
        'EmergencyAlert': await _dbHelper.getEmergencyAlertsByUser(userId),
        'FirstAidGuide': await _dbHelper.getAllFirstAidGuides(),
        'UserMedicalRecord': medicalRecord != null ? [medicalRecord] : [],
        'Medication': await _dbHelper.getMedicationsByUser(userId),
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: AppColors.blue,
        ),
      );
    }
  }

  Future<void> _clearAndReseed() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear and Reseed Database'),
          content: Text('Are you sure you want to clear all data and reseed it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _seeder.clearDatabase();
        await _seeder.seedDatabase();
        await _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database updated successfully'),
            backgroundColor: AppColors.lightGreen,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.blue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Database Viewer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.blue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: _clearAndReseed,
            tooltip: 'Clear and Reseed',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.blue,
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final tableName = _data.keys.elementAt(index);
                final tableData = _data[tableName]!;
                
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Icon(
                          _getTableIcon(tableName),
                          color: _getTableColor(tableName),
                        ),
                        SizedBox(width: 12),
                        Text(
                          tableName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTableColor(tableName).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${tableData.length}',
                            style: TextStyle(
                              color: _getTableColor(tableName),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: tableData.isEmpty
                        ? [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Aucune donnée',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ]
                        : tableData.map((item) {
                            return ListTile(
                              title: Text(
                                _getItemTitle(tableName, item),
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                _getItemSubtitle(tableName, item),
                                style: TextStyle(fontSize: 12),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              onTap: () {
                                _showItemDetails(tableName, item);
                              },
                            );
                          }).toList(),
                  ),
                );
              },
            ),
    );
  }

  IconData _getTableIcon(String tableName) {
    switch (tableName) {
      case 'EmergencyContact':
        return Icons.contacts;
      case 'EmergencyAlert':
        return Icons.warning;
      case 'FirstAidGuide':
        return Icons.medical_services;
      case 'UserMedicalRecord':
        return Icons.folder;
      case 'Medication':
        return Icons.medication;
      default:
        return Icons.table_chart;
    }
  }

  Color _getTableColor(String tableName) {
    // Map table types to the app palette; keep distinct colors where helpful
    switch (tableName) {
      case 'EmergencyContact':
        return AppColors.blue;
      case 'EmergencyAlert':
        return AppColors.lightGreen;
      case 'FirstAidGuide':
        return AppColors.lightGreen;
      case 'UserMedicalRecord':
        return AppColors.blue;
      case 'Medication':
        return AppColors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getItemTitle(String tableName, Map<String, dynamic> item) {
    switch (tableName) {
      case 'EmergencyContact':
        return item['full_name'] ?? 'Contact';
      case 'EmergencyAlert':
        return 'Alerte #${item['alert_id']}';
      case 'FirstAidGuide':
        return item['title'] ?? 'Guide';
      case 'UserMedicalRecord':
        return 'Dossier médical';
      case 'Medication':
        return item['name'] ?? 'Médicament';
      default:
        return 'Élément';
    }
  }

  String _getItemSubtitle(String tableName, Map<String, dynamic> item) {
    switch (tableName) {
      case 'EmergencyContact':
        return '${item['phone']} - ${item['relation'] ?? 'Contact'}';
      case 'EmergencyAlert':
        return '${item['status']} - ${item['created_at']}';
      case 'FirstAidGuide':
        return '${item['category']} - ${item['created_at']}';
      case 'UserMedicalRecord':
        return 'Groupe sanguin: ${item['blood_type'] ?? 'Non renseigné'}';
      case 'Medication':
        return '${item['dosage']} - ${item['frequency']}';
      default:
        return 'Détails';
    }
  }

  void _showItemDetails(String tableName, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(_getItemTitle(tableName, item)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: item.entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${entry.key}:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${entry.value ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
