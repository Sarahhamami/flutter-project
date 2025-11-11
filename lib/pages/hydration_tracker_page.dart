import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hydration_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/hydration/water_intake_card.dart';
import '../widgets/hydration/edit_water_dialog.dart';
import '../widgets/water_progress.dart';
import '../models/water_intake.dart';
import '../themes/app_theme.dart';

class HydrationTrackerPage extends StatefulWidget {
  const HydrationTrackerPage({super.key});

  @override
  State<HydrationTrackerPage> createState() => _HydrationTrackerPageState();
}

class _HydrationTrackerPageState extends State<HydrationTrackerPage> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HydrationProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi Hydratation'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'Informations',
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Consumer<HydrationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: provider.initialize,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section progression
                    _buildProgressSection(provider),
                    const SizedBox(height: 24),

                    // Section boutons rapides
                    _buildQuickAddSection(provider),
                    const SizedBox(height: 24),

                    // Section historique
                    _buildHistorySection(provider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWaterDialog,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Ajouter une prise d\'eau',
      ),
    );
  }

  Widget _buildProgressSection(HydrationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression du jour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider.isGoalReached
                        ? Colors.green.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.formattedProgress,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: provider.isGoalReached ? Colors.green : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            WaterProgress(
              consumed: provider.totalWaterToday,
              objectif: provider.dailyGoal,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${provider.formattedTotalWater} / ${provider.formattedGoal}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (provider.remainingWater > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${provider.remainingWater} ml restants',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddSection(HydrationProvider provider) {
    final quickAmounts = [250, 330, 500];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajout rapide',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: quickAmounts.map((amount) {
                return ElevatedButton.icon(
                  onPressed: () => _quickAddWater(provider, amount),
                  icon: const Icon(Icons.water_drop),
                  label: Text('${amount}ml'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(HydrationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Prises d\'eau du jour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${provider.waterIntakes.length} prise(s)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (provider.waterIntakes.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.waterIntakes.length,
            itemBuilder: (context, index) {
              final intake = provider.waterIntakes[index];
              return WaterIntakeCard(
                intake: intake,
                onEdit: () => _editWaterIntake(intake),
                onDelete: () => _deleteWaterIntake(intake.id),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 48,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune prise d\'eau enregistrée',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez par ajouter votre première prise d\'eau !',
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quickAddWater(HydrationProvider provider, int amount) async {
    final success = await provider.addQuickWaterIntake(amount);
    if (success && mounted) {
      // Mettre à jour le dashboard avec les nouvelles données d'eau
      await context.read<DashboardProvider>().updateWater(provider.totalWaterToday);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$amount ml ajoutés !'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'ajout')),
      );
    }
  }

  Future<void> _showAddWaterDialog() async {
    final WaterIntake? result = await showDialog<WaterIntake>(
      context: context,
      builder: (context) => const EditWaterDialog(),
    );

    if (result != null && mounted) {
      final success = await context.read<HydrationProvider>().addWaterIntake(result);
      if (success) {
        // Mettre à jour le dashboard avec les nouvelles données d'eau
        await context.read<DashboardProvider>().updateWater(context.read<HydrationProvider>().totalWaterToday);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prise d\'eau ajoutée !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout')),
        );
      }
    }
  }

  Future<void> _editWaterIntake(WaterIntake intake) async {
    final WaterIntake? result = await showDialog<WaterIntake>(
      context: context,
      builder: (context) => EditWaterDialog(initialIntake: intake),
    );

    if (result != null && mounted) {
      final success = await context.read<HydrationProvider>().updateWaterIntake(result);
      if (success) {
        // Mettre à jour le dashboard avec les nouvelles données d'eau
        await context.read<DashboardProvider>().updateWater(context.read<HydrationProvider>().totalWaterToday);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prise d\'eau modifiée !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la modification')),
        );
      }
    }
  }

  Future<void> _deleteWaterIntake(String id) async {
    final success = await context.read<HydrationProvider>().deleteWaterIntake(id);
    if (success && mounted) {
      // Mettre à jour le dashboard avec les nouvelles données d'eau
      await context.read<DashboardProvider>().updateWater(context.read<HydrationProvider>().totalWaterToday);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prise d\'eau supprimée !')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conseils d\'hydratation'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Buvez régulièrement tout au long de la journée'),
              Text('• Augmentez votre consommation par temps chaud'),
              Text('• Buvez avant, pendant et après l\'effort physique'),
              Text('• Surveillez la couleur de vos urines'),
              Text('• Les tisanes et soupes comptent aussi !'),
              SizedBox(height: 16),
              Text(
                'Objectif recommandé : 30-35 ml par kg de poids corporel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}