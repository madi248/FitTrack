import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import 'dart:async';

class AddFoodPage extends StatefulWidget {
  final VoidCallback onBack;
  final String? selectedMeal;
  final Function(FoodItem, String mealType) onAddFood;

  const AddFoodPage({
    super.key,
    required this.onBack,
    this.selectedMeal,
    required this.onAddFood,
  });

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<FoodItem> _searchResults = [];
  FoodItem? _selectedFood;
  bool _isLoading = false;
  String? _error;
  int _quantity = 1;
  String _selectedMealTime = 'Breakfast';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.selectedMeal != null) {
      _selectedMealTime = widget.selectedMeal == 'breakfast'
          ? 'Breakfast'
          : widget.selectedMeal == 'lunch'
              ? 'Lunch'
              : 'Dinner';
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    _debounceTimer?.cancel();

    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _error = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchFood(query);
    });
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _apiService.searchFood(query, pageSize: 15);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search foods. Please try again.';
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  void _selectFood(FoodItem food) {
    setState(() {
      _selectedFood = food;
      _searchController.clear();
      _searchResults = [];
      _quantity = 1;
    });
  }

  void _logFood() {
    if (_selectedFood == null) return;

    final totalCalories = (_selectedFood!.calories * _quantity).round();
    final totalProtein = ((_selectedFood!.protein * _quantity * 10).round()) / 10;
    final totalCarbs = ((_selectedFood!.carbs * _quantity * 10).round()) / 10;
    final totalFat = ((_selectedFood!.fat * _quantity * 10).round()) / 10;

    final mealType = _selectedMealTime.toLowerCase();

    final foodToLog = FoodItem(
      name: _selectedFood!.name,
      calories: totalCalories.toDouble(),
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      quantity: _quantity,
    );

    widget.onAddFood(foodToLog, mealType);
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final mealOptions = ['Breakfast', 'Lunch', 'Dinner'];
    final totalCalories = _selectedFood != null
        ? (_selectedFood!.calories * _quantity).round()
        : 0;
    final totalProtein = _selectedFood != null
        ? ((_selectedFood!.protein * _quantity * 10).round()) / 10
        : 0.0;
    final totalCarbs = _selectedFood != null
        ? ((_selectedFood!.carbs * _quantity * 10).round()) / 10
        : 0.0;
    final totalFat = _selectedFood != null
        ? ((_selectedFood!.fat * _quantity * 10).round()) / 10
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
                        onPressed: widget.onBack,
                      ),
                      const Expanded(
                        child: Text(
                          'Add Food',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search foods (e.g., apple, chicken breast)',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                        suffixIcon: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF14B8A6),
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error Message
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFFEF2F2),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFF991B1B), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            // Search Results
            if (_searchResults.isNotEmpty)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final food = _searchResults[index];
                      return InkWell(
                        onTap: () => _selectFood(food),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  food.name,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${food.calories.round()}',
                                    style: const TextStyle(
                                      color: Color(0xFF14B8A6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    'cal/100g',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: _selectedFood == null
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF14B8A6),
                                    Color(0xFF06B6D4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF14B8A6).withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.search, color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Search for Foods',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Use the search bar above to find foods from the database with accurate nutrition information',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selected Food Item Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 24))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              _quantity = (_quantity > 1) ? _quantity - 1 : 1;
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          width: 64,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            controller: TextEditingController(text: _quantity.toString())
                                              ..selection = TextSelection.collapsed(offset: _quantity.toString().length),
                                            onChanged: (value) {
                                              final qty = int.tryParse(value) ?? 1;
                                              setState(() {
                                                _quantity = qty > 0 ? qty : 1;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              _quantity++;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('×100g', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => const LinearGradient(
                                          colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                        ).createShader(bounds),
                                        child: Text(
                                          '$totalCalories',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const Text('cal', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _selectedFood!.name,
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Calories', style: TextStyle(color: Color(0xFF475569), fontSize: 15)),
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                    ).createShader(bounds),
                                    child: Text(
                                      '$totalCalories',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${totalProtein.toStringAsFixed(1)}g',
                                          style: const TextStyle(
                                            color: Color(0xFF14B8A6),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text('Protein', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${totalCarbs.toStringAsFixed(1)}g',
                                          style: const TextStyle(
                                            color: Color(0xFF06B6D4),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text('Carb', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${totalFat.toStringAsFixed(1)}g',
                                          style: const TextStyle(
                                            color: Color(0xFFEA580C),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text('Fat', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('When:', style: TextStyle(color: Color(0xFF1E293B), fontSize: 15)),
                                      Text(
                                        _selectedMealTime,
                                        style: const TextStyle(
                                          color: Color(0xFF1E293B),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: mealOptions.map((meal) {
                                      final isSelected = _selectedMealTime == meal;
                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _selectedMealTime = meal;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              decoration: BoxDecoration(
                                                gradient: isSelected
                                                    ? const LinearGradient(
                                                        colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                                      )
                                                    : null,
                                                color: isSelected ? null : Colors.white.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.transparent
                                                      : const Color(0xFFCBD5E1),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  meal,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
              ),
            ),

            // Log Food Button
            if (_selectedFood != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: _logFood,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Log $_quantity Serving${_quantity > 1 ? 's' : ''} ($totalCalories cal)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
