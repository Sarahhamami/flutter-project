import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_theme.dart';

class EditStepsDialog extends StatefulWidget {
  const EditStepsDialog({super.key});

  @override
  State<EditStepsDialog> createState() => _EditStepsDialogState();
}

class _EditStepsDialogState extends State<EditStepsDialog> {
  final TextEditingController _stepsController = TextEditingController();
  bool _isLoading = false;

  // Quantités prédéfinies pour boutons rapides
  final List<int> _quickAmounts = [1000, 2500, 5000, 7500, 10000];

  @override
  void initState() {
    super.initState();
    _stepsController.text = '0';
  }

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier les pas'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boutons de quantités rapides
            const Text(
              'Quantités rapides',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                return ElevatedButton(
                  onPressed: () => _setSteps(amount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text('${amount.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]} ',
                  )}'),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Champ nombre de pas personnalisé
            TextFormField(
              controller: _stepsController,
              decoration: const InputDecoration(
                labelText: 'Nombre de pas personnalisé',
                hintText: 'Ex: 8500',
                suffixText: 'pas',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Champ requis';
                final steps = int.tryParse(value);
                if (steps == null || steps < 0) return 'Nombre invalide';
                if (steps > 50000) return 'Nombre trop élevé (max 50 000)';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Informations sur les pas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Conseils :',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• 1 pas ≈ 0.76 mètre\n'
                    '• 2 000 pas ≈ 1.5 km\n'
                    '• 10 000 pas ≈ 7.5 km\n'
                    '• Objectif quotidien : 8 000 - 12 000 pas',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveSteps,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _setSteps(int steps) {
    setState(() {
      _stepsController.text = steps.toString();
    });
  }

  Future<void> _saveSteps() async {
    final steps = int.tryParse(_stepsController.text);
    if (steps == null || steps < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre de pas invalide')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Navigator.of(context).pop(steps);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}