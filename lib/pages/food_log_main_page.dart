import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/food_item.dart';
import '../models/daily_goals.dart';
import 'add_food_page.dart';
import 'profile_page.dart';
import '../widgets/bottom_nav.dart';

class FoodLogMainPage extends StatelessWidget {
  final Function(String, {String? meal, String? activity}) navigateTo;
  final MealsData meals;
  final DailyGoals dailyGoals;

  const FoodLogMainPage({
    super.key,
    required this.navigateTo,
    required this.meals,
    required this.dailyGoals,
  });

  int _getTotalCalories() {
    return (meals.breakfast.fold(0.0, (sum, m) => sum + m.calories) +
        meals.lunch.fold(0.0, (sum, m) => sum + m.calories) +
        meals.dinner.fold(0.0, (sum, m) => sum + m.calories)).round();
  }

  int _getMealCalories(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return meals.breakfast.fold(0.0, (sum, m) => sum + m.calories).round();
      case 'lunch':
        return meals.lunch.fold(0.0, (sum, m) => sum + m.calories).round();
      case 'dinner':
        return meals.dinner.fold(0.0, (sum, m) => sum + m.calories).round();
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final caloriesIntake = _getTotalCalories();
    final caloriesGoal = dailyGoals.calories;
    final caloriesRemaining = caloriesGoal - caloriesIntake;
    final caloriesPercentage = (caloriesIntake / caloriesGoal * 100).clamp(0.0, 100.0);

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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logo1.png',
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                      IconButton(
                        onPressed: () => navigateTo('profile'),
                        icon: Consumer<AppState>(
                          builder: (context, appState, _) {
                            final avatarUrl = appState.currentUser?['avatar_url'];
                            return Container(
                              width: 40,
                              height: 40, 
                              decoration: BoxDecoration(
                                gradient: avatarUrl == null
                                    ? const LinearGradient(
                                        colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                image: avatarUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(avatarUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: avatarUrl == null 
                                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  InkWell(
                    onTap: () => navigateTo('addfood'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[400], size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Search foods...',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calorie Ring Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's Calories",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Color(0xFF14B8A6),
                                          Color(0xFF06B6D4),
                                        ],
                                      ).createShader(bounds),
                                      child: Text(
                                        '$caloriesIntake',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '/ $caloriesGoal',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Remaining',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '$caloriesRemaining',
                                  style: const TextStyle(
                                    color: Color(0xFF14B8A6),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Circular Progress
                          SizedBox(
                            width: 96,
                            height: 96,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 96,
                                  height: 96,
                                  child: CircularProgressIndicator(
                                    value: caloriesPercentage / 100,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF14B8A6),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${caloriesPercentage.round()}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Meals Section
                    const Text(
                      'Meals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Breakfast
                    _buildMealCard(
                      context,
                      'Breakfast',
                      Icons.coffee,
                      _getMealCalories('breakfast'),
                      meals.breakfast,
                      () => navigateTo('addfood', meal: 'breakfast'),
                    ),
                    const SizedBox(height: 12),

                    // Lunch
                    _buildMealCard(
                      context,
                      'Lunch',
                      Icons.wb_sunny,
                      _getMealCalories('lunch'),
                      meals.lunch,
                      () => navigateTo('addfood', meal: 'lunch'),
                    ),
                    const SizedBox(height: 12),

                    // Dinner
                    _buildMealCard(
                      context,
                      'Dinner',
                      Icons.nightlight_round,
                      _getMealCalories('dinner'),
                      meals.dinner,
                      () => navigateTo('addfood', meal: 'dinner'),
                    ),

                    if (caloriesIntake == 0) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'No meals logged yet today',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your first meal!',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentPage: 'home',
        onNavigate: (page) => navigateTo(page),
      ),
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    String title,
    IconData icon,
    int calories,
    List<FoodItem> foods,
    VoidCallback onAdd,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.grey[600], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '$calories cal',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
          if (foods.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Column(
                children: foods.map((food) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              food.name,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 14,
                              ),
                            ),
                            if (food.quantity > 1) ...[
                              const SizedBox(width: 8),
                              Text(
                                'x${food.quantity}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${food.calories.round()} cal',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                              onPressed: () {
                                Provider.of<AppState>(context, listen: false)
                                    .removeFood(food, title.toLowerCase());
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
