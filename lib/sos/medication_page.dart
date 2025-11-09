import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/colors.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);
    try {
      // For now, we'll get all medications. In a real app, you'd filter by current user
      final medications = await _dbHelper.database.then((db) =>
        db.query('Medication', orderBy: 'created_at DESC')
      );
      setState(() {
        _medications = medications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading medications: $e')),
      );
    }
  }

  Future<void> _deleteMedication(int medicationId) async {
    try {
      await _dbHelper.deleteMedication(medicationId);
      _loadMedications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting medication: $e')),
      );
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? medication]) {
    showDialog(
      context: context,
      builder: (context) => MedicationDialog(
        medication: medication,
        onSave: (medicationData) async {
          try {
            if (medication == null) {
              await _dbHelper.createMedication(
                recordId: 1, // Default record for now
                name: medicationData['name']!,
                dosage: medicationData['dosage']!,
                frequency: medicationData['frequency']!,
                startDate: medicationData['start_date']!,
                endDate: medicationData['end_date'],
              );
            } else {
              await _dbHelper.updateMedication(
                medicationId: medication['medication_id'],
                name: medicationData['name'],
                dosage: medicationData['dosage'],
                frequency: medicationData['frequency'],
                startDate: medicationData['start_date'],
                endDate: medicationData['end_date'],
              );
            }
            _loadMedications();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(medication == null ? 'Medication added successfully' : 'Medication updated successfully')),
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
        title: const Text('Médications'),
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
          : _medications.isEmpty
              ? const Center(child: Text('Aucune médication trouvée'))
              : ListView.builder(
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final medication = _medications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(medication['name'] ?? ''),
                        subtitle: Text('${medication['dosage'] ?? ''} - ${medication['frequency'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddEditDialog(medication),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(medication),
                            ),
                          ],
                        ),
                        onTap: () => _showMedicationDetails(medication),
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${medication['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteMedication(medication['medication_id']);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMedicationDetails(Map<String, dynamic> medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medication['name'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Dosage: ${medication['dosage'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Fréquence: ${medication['frequency'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Date de début: ${medication['start_date'] ?? ''}'),
              const SizedBox(height: 8),
              if (medication['end_date'] != null)
                Text('Date de fin: ${medication['end_date']}'),
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

class MedicationDialog extends StatefulWidget {
  final Map<String, dynamic>? medication;
  final Function(Map<String, String?>) onSave;

  const MedicationDialog({super.key, this.medication, required this.onSave});

  @override
  State<MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<MedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  final List<String> _frequencies = [
    '1 fois par jour',
    '2 fois par jour',
    '3 fois par jour',
    '4 fois par jour',
    'Au besoin',
    'Toutes les 4 heures',
    'Toutes les 6 heures',
    'Toutes les 8 heures',
    'Toutes les 12 heures',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!['name'] ?? '';
      _dosageController.text = widget.medication!['dosage'] ?? '';
      _frequencyController.text = widget.medication!['frequency'] ?? '';
      _startDateController.text = widget.medication!['start_date'] ?? '';
      _endDateController.text = widget.medication!['end_date'] ?? '';
    } else {
      _startDateController.text = DateTime.now().toIso8601String().split('T')[0];
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom du médicament'),
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage (ex: 500mg, 1 comprimé)'),
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              DropdownButtonFormField<String>(
                value: _frequencyController.text.isNotEmpty ? _frequencyController.text : null,
                decoration: const InputDecoration(labelText: 'Fréquence'),
                items: _frequencies.map((freq) => DropdownMenuItem(
                  value: freq,
                  child: Text(freq),
                )).toList(),
                onChanged: (value) => _frequencyController.text = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Date de début',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _startDateController),
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'Date de fin (optionnel)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _endDateController),
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
        'name': _nameController.text,
        'dosage': _dosageController.text,
        'frequency': _frequencyController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text.isNotEmpty ? _endDateController.text : null,
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}