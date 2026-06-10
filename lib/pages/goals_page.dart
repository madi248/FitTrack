import 'package:flutter/material.dart';
import '../models/daily_goals.dart';

class GoalsPage extends StatefulWidget {
  final VoidCallback onBack;
  final DailyGoals currentGoals;
  final Function(DailyGoals) onSaveGoals;

  const GoalsPage({
    super.key,
    required this.onBack,
    required this.currentGoals,
    required this.onSaveGoals,
  });

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late TextEditingController _calorieController;
  late TextEditingController _caloriesToBurnController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  bool _showSaveSuccess = false;

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController(text: widget.currentGoals.calories.toString());
    _caloriesToBurnController = TextEditingController(text: widget.currentGoals.caloriesToBurn.toString());
    _proteinController = TextEditingController(text: widget.currentGoals.protein.toString());
    _carbsController = TextEditingController(text: widget.currentGoals.carbs.toString());
    _fatController = TextEditingController(text: widget.currentGoals.fat.toString());
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _caloriesToBurnController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final newGoals = DailyGoals(
      calories: int.tryParse(_calorieController.text) ?? 2000,
      caloriesToBurn: int.tryParse(_caloriesToBurnController.text) ?? 500,
      protein: int.tryParse(_proteinController.text) ?? 150,
      carbs: int.tryParse(_carbsController.text) ?? 200,
      fat: int.tryParse(_fatController.text) ?? 67,
    );

    widget.onSaveGoals(newGoals);
    setState(() {
      _showSaveSuccess = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onBack();
      }
    });
  }

  double _calculateMacroPercent(int value, int total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final protein = int.tryParse(_proteinController.text) ?? 0;
    final carbs = int.tryParse(_carbsController.text) ?? 0;
    final fat = int.tryParse(_fatController.text) ?? 0;
    final totalCaloriesFromMacros = (protein * 4) + (carbs * 4) + (fat * 9);
    final proteinPercent = _calculateMacroPercent(protein * 4, totalCaloriesFromMacros);
    final carbsPercent = _calculateMacroPercent(carbs * 4, totalCaloriesFromMacros);
    final fatPercent = _calculateMacroPercent(fat * 9, totalCaloriesFromMacros);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goals & Targets',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Set your fitness objectives',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Targets
            const Text(
              'Daily Targets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildGoalInput(
                    controller: _calorieController,
                    label: 'Daily Calorie Goal',
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFFEA580C),
                    suffix: 'kcal',
                  ),
                  const SizedBox(height: 20),
                  _buildGoalInput(
                    controller: _caloriesToBurnController,
                    label: 'Calories to Burn',
                    icon: Icons.bolt,
                    iconColor: const Color(0xFF14B8A6),
                    suffix: 'kcal',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Macro Nutrient Targets
            const Text(
              'Macro Nutrient Targets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildMacroInput(
                    controller: _proteinController,
                    label: 'Protein',
                    icon: Icons.restaurant,
                    iconColor: const Color(0xFFE11D48),
                    suffix: 'g',
                    percent: proteinPercent,
                    color: const Color(0xFFE11D48),
                  ),
                  const SizedBox(height: 20),
                  _buildMacroInput(
                    controller: _carbsController,
                    label: 'Carbohydrates',
                    icon: Icons.eco,
                    iconColor: const Color(0xFFF59E0B),
                    suffix: 'g',
                    percent: carbsPercent,
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 20),
                  _buildMacroInput(
                    controller: _fatController,
                    label: 'Fats',
                    icon: Icons.water_drop,
                    iconColor: const Color(0xFF3B82F6),
                    suffix: 'g',
                    percent: fatPercent,
                    color: const Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF14B8A6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Goals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            if (_showSaveSuccess) ...[
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Goals saved successfully!',
                  style: TextStyle(
                    color: Color(0xFF14B8A6),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required String suffix,
    required double percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${percent.round()}%',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
