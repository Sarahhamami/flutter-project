import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/water_intake.dart';
import '../../themes/app_theme.dart';

class EditWaterDialog extends StatefulWidget {
  final WaterIntake? initialIntake;

  const EditWaterDialog({super.key, this.initialIntake});

  @override
  State<EditWaterDialog> createState() => _EditWaterDialogState();
}

class _EditWaterDialogState extends State<EditWaterDialog> {
  late TextEditingController _quantityController;
  late TextEditingController _noteController;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  // Quantités prédéfinies pour boutons rapides
  final List<int> _quickAmounts = [100, 200, 250, 330, 500, 750];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.initialIntake?.quantity.toString() ?? '250',
    );
    _noteController = TextEditingController(
      text: widget.initialIntake?.note ?? '',
    );
    _selectedTime = widget.initialIntake?.time ?? TimeOfDay.now();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialIntake != null;

    return AlertDialog(
      title: Text(isEditing ? 'Modifier la prise d\'eau' : 'Ajouter de l\'eau'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boutons de quantités rapides
            const Text(
              'Quantité rapide',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                return ElevatedButton(
                  onPressed: () => _setQuantity(amount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text('${amount}ml'),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Champ quantité personnalisée
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantité personnalisée (ml)',
                hintText: 'Ex: 300',
                suffixText: 'ml',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Champ requis';
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) return 'Quantité invalide';
                if (quantity > 2000) return 'Quantité trop élevée';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Sélecteur d'heure
            Row(
              children: [
                const Text('Heure: '),
                TextButton(
                  onPressed: _selectTime,
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Champ note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
                hintText: 'Ex: Avec un repas, après le sport...',
              ),
              maxLines: 2,
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
          onPressed: _isLoading ? null : _saveWaterIntake,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Modifier' : 'Ajouter'),
        ),
      ],
    );
  }

  void _setQuantity(int amount) {
    setState(() {
      _quantityController.text = amount.toString();
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveWaterIntake() async {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantité invalide')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final waterIntake = WaterIntake(
        date: widget.initialIntake?.date ?? DateTime.now(),
        quantity: quantity,
        time: _selectedTime,
        note: _noteController.text.trim(),
        id: widget.initialIntake?.id,
      );

      Navigator.of(context).pop(waterIntake);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}