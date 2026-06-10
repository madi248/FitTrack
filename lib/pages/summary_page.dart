import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../models/daily_goals.dart';
import '../widgets/bottom_nav.dart';

class SummaryPage extends StatelessWidget {
  final Function(String) navigateTo;
  final MealsData meals;
  final DailyGoals dailyGoals;

  const SummaryPage({
    super.key,
    required this.navigateTo,
    required this.meals,
    required this.dailyGoals,
  });

  Map<String, dynamic> _calculateTotals() {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var mealArray in [meals.breakfast, meals.lunch, meals.dinner]) {
      for (var food in mealArray) {
        totalCalories += food.calories;
        totalProtein += food.protein;
        totalCarbs += food.carbs;
        totalFat += food.fat;
      }
    }

    return {
      'calories': totalCalories.round(),
      'protein': (totalProtein * 10).round() / 10,
      'carbs': (totalCarbs * 10).round() / 10,
      'fat': (totalFat * 10).round() / 10,
    };
  }

  int _getMealCalories(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return meals.breakfast.fold(0, (sum, f) => sum + f.calories.round());
      case 'lunch':
        return meals.lunch.fold(0, (sum, f) => sum + f.calories.round());
      case 'dinner':
        return meals.dinner.fold(0, (sum, f) => sum + f.calories.round());
      default:
        return 0;
    }
  }

  Map<String, double> _getMealMacros(String mealType) {
    List<FoodItem> meal;
    switch (mealType) {
      case 'breakfast':
        meal = meals.breakfast;
        break;
      case 'lunch':
        meal = meals.lunch;
        break;
      case 'dinner':
        meal = meals.dinner;
        break;
      default:
        meal = [];
    }

    return {
      'protein': (meal.fold(0.0, (sum, f) => sum + f.protein) * 10).round() / 10,
      'carbs': (meal.fold(0.0, (sum, f) => sum + f.carbs) * 10).round() / 10,
      'fat': (meal.fold(0.0, (sum, f) => sum + f.fat) * 10).round() / 10,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();
    final caloriesGoal = dailyGoals.calories;
    final caloriesRemaining = caloriesGoal - totals['calories'] as int;
    final hasLoggedFood = totals['calories'] as int > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  'Daily Summary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calories Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Calories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                hasLoggedFood
                                    ? '${(((totals['calories'] as int) / caloriesGoal) * 100).round()}%'
                                    : '0%',
                                style: const TextStyle(
                                  color: Color(0xFF14B8A6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Consumed', style: TextStyle(color: Color(0xFF64748B))),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                ).createShader(bounds),
                                child: Text(
                                  '${totals['calories']} / $caloriesGoal cal',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: ((totals['calories'] as int) / caloriesGoal.toDouble()).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey[200]!, width: 1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Remaining', style: TextStyle(color: Color(0xFF64748B))),
                                Text(
                                  '${caloriesRemaining.abs()} cal ${caloriesRemaining < 0 ? 'over' : ''}',
                                  style: TextStyle(
                                    color: caloriesRemaining >= 0
                                        ? const Color(0xFF14B8A6)
                                        : const Color(0xFFEA580C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Macros Summary
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Macronutrients',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildMacroRow('Protein', totals['protein'] as double, dailyGoals.protein.toDouble()),
                          const SizedBox(height: 16),
                          _buildMacroRow('Carbs', totals['carbs'] as double, dailyGoals.carbs.toDouble()),
                          const SizedBox(height: 16),
                          _buildMacroRow('Fat', totals['fat'] as double, dailyGoals.fat.toDouble()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Meals Breakdown
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meals Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMealBreakdown('breakfast', Icons.coffee, 'Breakfast'),
                          const SizedBox(height: 12),
                          _buildMealBreakdown('lunch', Icons.wb_sunny, 'Lunch'),
                          const SizedBox(height: 12),
                          _buildMealBreakdown('dinner', Icons.nightlight_round, 'Dinner'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Empty State or Tips
                    if (!hasLoggedFood)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.trending_up, color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No meals logged yet today',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start logging your meals to track your nutrition and reach your goals!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: const Center(
                          child: Text(
                            'Keep up the great work! 💪',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentPage: 'summary',
        onNavigate: navigateTo,
      ),
    );
  }

  Widget _buildMacroRow(String name, double current, double goal) {
    final percentage = (current / goal * 100).clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(color: Color(0xFF64748B))),
            Text(
              '${current.toStringAsFixed(1)}g / ${goal.toInt()}g',
              style: const TextStyle(color: Color(0xFF1E293B)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildMealBreakdown(String mealType, IconData icon, String title) {
    final calories = _getMealCalories(mealType);
    final macros = _getMealMacros(mealType);
    List<FoodItem> meal;
    switch (mealType) {
      case 'breakfast':
        meal = meals.breakfast;
        break;
      case 'lunch':
        meal = meals.lunch;
        break;
      case 'dinner':
        meal = meals.dinner;
        break;
      default:
        meal = [];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.grey[600], size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                '$calories cal',
                style: TextStyle(
                  color: calories > 0 ? const Color(0xFF14B8A6) : Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (meal.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Row(
                children: [
                  Text('P: ${macros['protein']!.toStringAsFixed(1)}g', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('C: ${macros['carbs']!.toStringAsFixed(1)}g', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('F: ${macros['fat']!.toStringAsFixed(1)}g', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
