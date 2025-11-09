import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class MedicalQRPage extends StatefulWidget {
  const MedicalQRPage({super.key});

  @override
  State<MedicalQRPage> createState() => _MedicalQRPageState();
}

class _MedicalQRPageState extends State<MedicalQRPage> {
  Map<String, String> _medicalInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicalInfo();
  }

  Future<void> _loadMedicalInfo() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _medicalInfo = {
          'name': prefs.getString('medical_name') ?? '',
          'age': prefs.getString('medical_age') ?? '',
          'blood_type': prefs.getString('medical_blood_type') ?? '',
          'allergies': prefs.getString('medical_allergies') ?? '',
          'diseases': prefs.getString('medical_diseases') ?? '',
          'medications': prefs.getString('medical_medications') ?? '',
          'emergency_contact': prefs.getString('medical_emergency_contact') ?? '',
          'emergency_phone': prefs.getString('medical_emergency_phone') ?? '',
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading medical information: $e')),
      );
    }
  }

  Future<void> _saveMedicalInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('medical_name', _medicalInfo['name'] ?? '');
      await prefs.setString('medical_age', _medicalInfo['age'] ?? '');
      await prefs.setString('medical_blood_type', _medicalInfo['blood_type'] ?? '');
      await prefs.setString('medical_allergies', _medicalInfo['allergies'] ?? '');
      await prefs.setString('medical_diseases', _medicalInfo['diseases'] ?? '');
      await prefs.setString('medical_medications', _medicalInfo['medications'] ?? '');
      await prefs.setString('medical_emergency_contact', _medicalInfo['emergency_contact'] ?? '');
      await prefs.setString('medical_emergency_phone', _medicalInfo['emergency_phone'] ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical information updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving medical information: $e')),
      );
    }
  }

  String _generateQRData() {
    return '''
EMERGENCY MEDICAL INFORMATION
Name: ${_medicalInfo['name']}
Age: ${_medicalInfo['age']}
Blood Type: ${_medicalInfo['blood_type']}
Allergies: ${_medicalInfo['allergies']}
Chronic Diseases: ${_medicalInfo['diseases']}
Current Medications: ${_medicalInfo['medications']}
Emergency Contact: ${_medicalInfo['emergency_contact']}
Emergency Phone: ${_medicalInfo['emergency_phone']}
Generated: ${DateTime.now().toString()}
    '''.trim();
  }

  bool get _hasCompleteInfo {
    return _medicalInfo['name']?.isNotEmpty == true &&
           _medicalInfo['blood_type']?.isNotEmpty == true &&
           _medicalInfo['emergency_contact']?.isNotEmpty == true &&
           _medicalInfo['emergency_phone']?.isNotEmpty == true;
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => MedicalInfoDialog(
        medicalInfo: _medicalInfo,
        onSave: (updatedInfo) {
          setState(() => _medicalInfo = updatedInfo);
          _saveMedicalInfo();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Card'),
        backgroundColor: AppColors.lightGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
            tooltip: 'Update medical information',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  const Text(
                    'Emergency Medical Card',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Show this QR code to medical personnel in case of emergency',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // QR Code Section - Only show QR code if info is complete
                  if (_hasCompleteInfo) ...[
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _generateQRData(),
                          version: QrVersions.auto,
                          size: 250.0,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Emergency Medical Card',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 64,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Medical Information Incomplete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please complete your medical information to generate the QR code',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.orange),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showEditDialog,
                            icon: const Icon(Icons.edit),
                            label: const Text('Update Information'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                ],
              ),
            ),
    );
  }

}

class MedicalInfoDialog extends StatefulWidget {
  final Map<String, String> medicalInfo;
  final Function(Map<String, String>) onSave;

  const MedicalInfoDialog({
    super.key,
    required this.medicalInfo,
    required this.onSave,
  });

  @override
  State<MedicalInfoDialog> createState() => _MedicalInfoDialogState();
}

class _MedicalInfoDialogState extends State<MedicalInfoDialog> {
  late Map<String, String> _info;

  @override
  void initState() {
    super.initState();
    _info = Map.from(widget.medicalInfo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Medical Information'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Name', 'name'),
            _buildTextField('Age', 'age'),
            _buildTextField('Blood Type (e.g., A+, O-)', 'blood_type'),
            _buildTextField('Allergies', 'allergies', maxLines: 2),
            _buildTextField('Chronic Diseases', 'diseases', maxLines: 2),
            _buildTextField('Current Medications', 'medications', maxLines: 2),
            _buildTextField('Emergency Contact Name', 'emergency_contact'),
            _buildTextField('Emergency Contact Phone', 'emergency_phone'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_info);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String key, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        controller: TextEditingController(text: _info[key]),
        onChanged: (value) => _info[key] = value,
      ),
    );
  }
}