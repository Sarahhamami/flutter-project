import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/colors.dart';

class UserMedicalRecordPage extends StatefulWidget {
  const UserMedicalRecordPage({super.key});

  @override
  State<UserMedicalRecordPage> createState() => _UserMedicalRecordPageState();
}

class _UserMedicalRecordPageState extends State<UserMedicalRecordPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      // For now, we'll get all records. In a real app, you'd filter by current user
      final records = await _dbHelper.database.then((db) =>
        db.query('UserMedicalRecord')
      );
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading records: $e')),
      );
    }
  }

  Future<void> _deleteRecord(int recordId) async {
    try {
      await _dbHelper.deleteUserMedicalRecord(recordId);
      _loadRecords();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical record deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting record: $e')),
      );
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? record]) {
    showDialog(
      context: context,
      builder: (context) => UserMedicalRecordDialog(
        record: record,
        onSave: (recordData) async {
          try {
            if (record == null) {
              await _dbHelper.createUserMedicalRecord(
                userId: 1, // Default user for now
                bloodType: recordData['blood_type']!,
                chronicDiseases: recordData['chronic_diseases']!,
                allergies: recordData['allergies']!,
                currentTreatments: recordData['current_treatments']!,
                doctorName: recordData['doctor_name']!,
                doctorPhone: recordData['doctor_phone']!,
              );
            } else {
              await _dbHelper.updateUserMedicalRecord(
                recordId: record['record_id'],
                bloodType: recordData['blood_type'],
                chronicDiseases: recordData['chronic_diseases'],
                allergies: recordData['allergies'],
                currentTreatments: recordData['current_treatments'],
                doctorName: recordData['doctor_name'],
                doctorPhone: recordData['doctor_phone'],
              );
            }
            _loadRecords();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(record == null ? 'Medical record added successfully' : 'Medical record updated successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossiers Médicaux'),
        backgroundColor: AppColors.lightGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text('Aucun dossier médical trouvé'))
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Groupe sanguin: ${record['blood_type'] ?? ''}'),
                        subtitle: Text('Docteur: ${record['doctor_name'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddEditDialog(record),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(record),
                            ),
                          ],
                        ),
                        onTap: () => _showRecordDetails(record),
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this medical record? All associated medications will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteRecord(record['record_id']);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails du dossier médical'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Groupe sanguin: ${record['blood_type'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Maladies chroniques: ${record['chronic_diseases'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Allergies: ${record['allergies'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Traitements actuels: ${record['current_treatments'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Docteur: ${record['doctor_name'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Téléphone du docteur: ${record['doctor_phone'] ?? ''}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class UserMedicalRecordDialog extends StatefulWidget {
  final Map<String, dynamic>? record;
  final Function(Map<String, String>) onSave;

  const UserMedicalRecordDialog({super.key, this.record, required this.onSave});

  @override
  State<UserMedicalRecordDialog> createState() => _UserMedicalRecordDialogState();
}

class _UserMedicalRecordDialogState extends State<UserMedicalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bloodTypeController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _currentTreatmentsController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _doctorPhoneController = TextEditingController();

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _bloodTypeController.text = widget.record!['blood_type'] ?? '';
      _chronicDiseasesController.text = widget.record!['chronic_diseases'] ?? '';
      _allergiesController.text = widget.record!['allergies'] ?? '';
      _currentTreatmentsController.text = widget.record!['current_treatments'] ?? '';
      _doctorNameController.text = widget.record!['doctor_name'] ?? '';
      _doctorPhoneController.text = widget.record!['doctor_phone'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.record == null ? 'Add Medical Record' : 'Edit Medical Record'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _bloodTypeController.text.isNotEmpty ? _bloodTypeController.text : null,
                decoration: const InputDecoration(labelText: 'Groupe sanguin'),
                items: _bloodTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) => _bloodTypeController.text = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _chronicDiseasesController,
                decoration: const InputDecoration(labelText: 'Maladies chroniques'),
                maxLines: 2,
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(labelText: 'Allergies'),
                maxLines: 2,
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _currentTreatmentsController,
                decoration: const InputDecoration(labelText: 'Traitements actuels'),
                maxLines: 2,
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _doctorNameController,
                decoration: const InputDecoration(labelText: 'Nom du docteur'),
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _doctorPhoneController,
                decoration: const InputDecoration(labelText: 'Téléphone du docteur'),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        'blood_type': _bloodTypeController.text,
        'chronic_diseases': _chronicDiseasesController.text,
        'allergies': _allergiesController.text,
        'current_treatments': _currentTreatmentsController.text,
        'doctor_name': _doctorNameController.text,
        'doctor_phone': _doctorPhoneController.text,
      });
    }
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _chronicDiseasesController.dispose();
    _allergiesController.dispose();
    _currentTreatmentsController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    super.dispose();
  }
}