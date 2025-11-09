import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/colors.dart';

class FirstAidGuidePage extends StatefulWidget {
  const FirstAidGuidePage({super.key});

  @override
  State<FirstAidGuidePage> createState() => _FirstAidGuidePageState();
}

class _FirstAidGuidePageState extends State<FirstAidGuidePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _guides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    setState(() => _isLoading = true);
    try {
      final guides = await _dbHelper.getAllFirstAidGuides();
      setState(() {
        _guides = guides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading guides: $e')),
      );
    }
  }

  Future<void> _deleteGuide(int guideId) async {
    try {
      await _dbHelper.deleteFirstAidGuide(guideId);
      _loadGuides();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guide deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting guide: $e')),
      );
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? guide]) {
    showDialog(
      context: context,
      builder: (context) => FirstAidGuideDialog(
        guide: guide,
        onSave: (guideData) async {
          try {
            if (guide == null) {
              await _dbHelper.createFirstAidGuide(
                title: guideData['title']!,
                description: guideData['description']!,
                stepByStep: guideData['step_by_step']!,
                category: guideData['category']!,
                imageUrl: guideData['image_url']!,
              );
            } else {
              await _dbHelper.updateFirstAidGuide(
                guideId: guide['guide_id'],
                title: guideData['title'],
                description: guideData['description'],
                stepByStep: guideData['step_by_step'],
                category: guideData['category'],
                imageUrl: guideData['image_url'],
              );
            }
            _loadGuides();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(guide == null ? 'Guide added successfully' : 'Guide updated successfully')),
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
        title: const Text('Guides Premiers Secours'),
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
          : _guides.isEmpty
              ? const Center(child: Text('Aucun guide trouvé'))
              : ListView.builder(
                  itemCount: _guides.length,
                  itemBuilder: (context, index) {
                    final guide = _guides[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(guide['title'] ?? ''),
                        subtitle: Text(guide['category'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddEditDialog(guide),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(guide),
                            ),
                          ],
                        ),
                        onTap: () => _showGuideDetails(guide),
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${guide['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteGuide(guide['guide_id']);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showGuideDetails(Map<String, dynamic> guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(guide['title'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Catégorie: ${guide['category'] ?? ''}'),
              const SizedBox(height: 16),
              Text('Description:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(guide['description'] ?? ''),
              const SizedBox(height: 16),
              Text('Étapes:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(guide['step_by_step'] ?? ''),
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

class FirstAidGuideDialog extends StatefulWidget {
  final Map<String, dynamic>? guide;
  final Function(Map<String, String>) onSave;

  const FirstAidGuideDialog({super.key, this.guide, required this.onSave});

  @override
  State<FirstAidGuideDialog> createState() => _FirstAidGuideDialogState();
}

class _FirstAidGuideDialogState extends State<FirstAidGuideDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepByStepController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.guide != null) {
      _titleController.text = widget.guide!['title'] ?? '';
      _descriptionController.text = widget.guide!['description'] ?? '';
      _stepByStepController.text = widget.guide!['step_by_step'] ?? '';
      _categoryController.text = widget.guide!['category'] ?? '';
      _imageUrlController.text = widget.guide!['image_url'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.guide == null ? 'Add Guide' : 'Edit Guide'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _stepByStepController,
                decoration: const InputDecoration(labelText: 'Étapes détaillées'),
                maxLines: 5,
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de l\'image'),
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
        'title': _titleController.text,
        'description': _descriptionController.text,
        'step_by_step': _stepByStepController.text,
        'category': _categoryController.text,
        'image_url': _imageUrlController.text,
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepByStepController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}