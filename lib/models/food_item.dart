class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int quantity;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String? ?? json['description'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'quantity': quantity,
    };
  }
}

class MealsData {
  final List<FoodItem> breakfast;
  final List<FoodItem> lunch;
  final List<FoodItem> dinner;

  MealsData({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory MealsData.fromJson(Map<String, dynamic> json) {
    return MealsData(
      breakfast: (json['breakfast'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lunch: (json['lunch'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dinner: (json['dinner'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast.map((e) => e.toJson()).toList(),
      'lunch': lunch.map((e) => e.toJson()).toList(),
      'dinner': dinner.map((e) => e.toJson()).toList(),
    };
  }

  MealsData copyWith({
    List<FoodItem>? breakfast,
    List<FoodItem>? lunch,
    List<FoodItem>? dinner,
  }) {
    return MealsData(
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
    );
  }
}
