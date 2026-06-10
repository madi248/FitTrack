class DailyGoals {
  final int calories;
  final int caloriesToBurn;
  final int protein;
  final int carbs;
  final int fat;

  DailyGoals({
    required this.calories,
    required this.caloriesToBurn,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory DailyGoals.fromJson(Map<String, dynamic> json) {
    return DailyGoals(
      calories: json['calories'] as int? ?? 2000,
      caloriesToBurn: json['caloriesToBurn'] as int? ?? 500,
      protein: json['protein'] as int? ?? 150,
      carbs: json['carbs'] as int? ?? 200,
      fat: json['fat'] as int? ?? 67,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'caloriesToBurn': caloriesToBurn,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  DailyGoals copyWith({
    int? calories,
    int? caloriesToBurn,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return DailyGoals(
      calories: calories ?? this.calories,
      caloriesToBurn: caloriesToBurn ?? this.caloriesToBurn,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}
