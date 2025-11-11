import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/nutrition_profile.dart';
import '../services/sqlite_nutrition_service.dart';
import '../utils/calculs_nutritionnels.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_button.dart';
import '../widgets/modern_progress_indicator.dart';
import '../widgets/loading_animation.dart';
import '../themes/app_theme.dart';
import 'dashboard_page.dart';

class NutritionProfilePage extends StatefulWidget {
  const NutritionProfilePage({super.key});

  @override
  State<NutritionProfilePage> createState() => _NutritionProfilePageState();
}

class _NutritionProfilePageState extends State<NutritionProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showResults = false;
  bool _hasCalculatedOnce = false;

  // Contrôleurs pour les champs de texte
  final TextEditingController _poidsController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Valeurs des champs
  String _sexe = 'homme';
  String _objectif = 'maintien';
  String _niveauActivite = 'modere';

  // Profil calculé
  NutritionProfile? _calculatedProfile;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _poidsController.dispose();
    _tailleController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await SqliteNutritionService.getNutritionProfile();
      if (profile != null) {
        _poidsController.text = profile.poids.toString();
        _tailleController.text = profile.taille.toString();
        _ageController.text = profile.age.toString();
        _sexe = profile.sexe;
        _objectif = profile.objectif;
        _niveauActivite = profile.niveauActivite;
        _calculatedProfile = profile;
        _showResults = true;
      }
    } catch (e) {
      _showSnackBar('Erreur lors du chargement du profil', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateProfile() {
    if (!_formKey.currentState!.validate()) return;

    final poids = double.tryParse(_poidsController.text) ?? 0;
    final taille = double.tryParse(_tailleController.text) ?? 0;
    final age = int.tryParse(_ageController.text) ?? 0;

    final profile = NutritionProfile(
      poids: poids,
      taille: taille,
      age: age,
      sexe: _sexe,
      objectif: _objectif,
      niveauActivite: _niveauActivite,
    );

    profile.updateCalculatedGoals();

    setState(() {
      _calculatedProfile = profile;
      _showResults = true;
      _hasCalculatedOnce = true;
    });
  }

  Future<void> _saveProfile() async {
    if (_calculatedProfile == null) {
      _showSnackBar('Veuillez d\'abord calculer votre profil', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await SqliteNutritionService.saveNutritionProfile(_calculatedProfile!);
      if (success) {
        // Redirection automatique vers le dashboard
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      } else {
        _showSnackBar('Erreur lors de la sauvegarde', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sauvegarde', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profil Nutritionnel'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkGrey,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: _isLoading
            ? const Center(
                child: ModernLoadingAnimation(
                  message: 'Chargement de votre profil...',
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 100),
                child: Form(
                  key: _formKey,
                  child: AnimationLimiter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 600),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          _buildFormSection(),
                          const SizedBox(height: 24),
                          if (_hasCalculatedOnce && _showResults && _calculatedProfile != null) _buildResultsSection(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFormSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations personnelles',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Poids
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _poidsController,
              decoration: InputDecoration(
                labelText: 'Poids (kg)',
                hintText: 'Ex: 70.5',
                suffixText: 'kg',
                prefixIcon: Icon(Icons.monitor_weight, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Champ requis';
                final poids = double.tryParse(value);
                if (poids == null) return 'Nombre invalide';
                final error = CalculsNutritionnels.validerPoids(poids);
                return error;
              },
              onChanged: (_) => _calculateProfile(),
            ),
          ),
          const SizedBox(height: 16),

          // Taille
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _tailleController,
              decoration: InputDecoration(
                labelText: 'Taille (cm)',
                hintText: 'Ex: 175',
                suffixText: 'cm',
                prefixIcon: Icon(Icons.height, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Champ requis';
                final taille = double.tryParse(value);
                if (taille == null) return 'Nombre invalide';
                final error = CalculsNutritionnels.validerTaille(taille);
                return error;
              },
              // Removed automatic calculation
            ),
          ),
          const SizedBox(height: 16),

          // Âge
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Âge',
                hintText: 'Ex: 30',
                suffixText: 'ans',
                prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Champ requis';
                final age = int.tryParse(value);
                if (age == null) return 'Nombre invalide';
                final error = CalculsNutritionnels.validerAge(age);
                return error;
              },
              // Removed automatic calculation
            ),
          ),
          const SizedBox(height: 20),

          // Sexe avec boutons modernes
          Text(
            'Sexe',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModernButton(
                  onPressed: () {
                    setState(() => _sexe = 'homme');
                    // Removed automatic calculation
                  },
                  backgroundColor: _sexe == 'homme' ? AppColors.primary : AppColors.glassBackground,
                  foregroundColor: _sexe == 'homme' ? AppColors.white : AppColors.darkGrey,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        color: _sexe == 'homme' ? AppColors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Homme'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernButton(
                  onPressed: () {
                    setState(() => _sexe = 'femme');
                    // Removed automatic calculation
                  },
                  backgroundColor: _sexe == 'femme' ? AppColors.primary : AppColors.glassBackground,
                  foregroundColor: _sexe == 'femme' ? AppColors.white : AppColors.darkGrey,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: _sexe == 'femme' ? AppColors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Femme'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Objectif avec dropdown moderne
          Text(
            'Objectif',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _objectif,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.flag, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              items: const [
                DropdownMenuItem(value: 'perte', child: Text('Perte de poids')),
                DropdownMenuItem(value: 'maintien', child: Text('Maintien du poids')),
                DropdownMenuItem(value: 'prise_masse', child: Text('Prise de masse')),
              ],
              onChanged: (value) {
                setState(() => _objectif = value!);
                // Removed automatic calculation
              },
            ),
          ),
          const SizedBox(height: 16),

          // Niveau d'activité avec dropdown moderne
          Text(
            'Niveau d\'activité',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _niveauActivite,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.directions_run, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              items: const [
                DropdownMenuItem(value: 'sedentaire', child: Text('Sédentaire')),
                DropdownMenuItem(value: 'leger', child: Text('Légèrement actif')),
                DropdownMenuItem(value: 'modere', child: Text('Modérément actif')),
                DropdownMenuItem(value: 'actif', child: Text('Très actif')),
                DropdownMenuItem(value: 'tres_actif', child: Text('Extrêmement actif')),
              ],
              onChanged: (value) {
                setState(() => _niveauActivite = value!);
                // Removed automatic calculation
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final profile = _calculatedProfile!;
    final imc = CalculsNutritionnels.calculerIMC(profile.poids, profile.taille);
    final imcCategory = CalculsNutritionnels.classifierIMC(imc);

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos objectifs nutritionnels',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // IMC avec indicateur visuel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ModernProgressIndicator(
                  progress: imc / 40, // Normalisé pour l'indicateur
                  size: 60,
                  color: AppColors.primary,
                  label: 'IMC',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${imc.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        imcCategory,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Calories avec gauge
          _buildGoalGauge(
            'Calories par jour',
            profile.calorieObjectif.round(),
            'kcal',
            AppColors.primary,
            Icons.local_fire_department,
          ),
          const SizedBox(height: 16),

          // Macronutriments avec gauges individuelles
          Text(
            'Macronutriments quotidiens',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMacroGauge('Protéines', profile.proteineObjectif.round(), 'g', AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroGauge('Glucides', profile.glucideObjectif.round(), 'g', AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroGauge('Lipides', profile.lipideObjectif.round(), 'g', AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Autres objectifs
          Row(
            children: [
              Expanded(
                child: _buildGoalCard('Eau par jour', '${profile.eauObjectif} ml', Icons.water_drop, AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalCard('Pas par jour', '${profile.pasObjectif} pas', Icons.directions_walk, AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isSubItem = false}) {
    return Padding(
      padding: EdgeInsets.only(left: isSubItem ? 16 : 0, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSubItem ? FontWeight.normal : FontWeight.w600,
              color: isSubItem ? AppColors.grey : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ModernButton(
          onPressed: _calculateProfile,
          gradient: AppColors.primaryGradient,
          padding: const EdgeInsets.symmetric(vertical: 18),
          borderRadius: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calculate, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Calculer mon profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_hasCalculatedOnce && _showResults)
          ModernButton(
            onPressed: _isLoading ? null : _saveProfile,
            gradient: AppColors.secondaryGradient,
            padding: const EdgeInsets.symmetric(vertical: 18),
            borderRadius: 16,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: AppColors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Sauvegarder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }
}
  Widget _buildGoalGauge(String label, int value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$value $unit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroGauge(String label, int value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }