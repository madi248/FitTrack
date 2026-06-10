import 'package:flutter_test/flutter_test.dart';
import 'package:fit_track_mobile/models/food_item.dart';

void main() {
  group('FoodItem', () {
    test('fromJson creates instance with correct values', () {
      final json = {
        'name': 'Apple',
        'calories': 95.0,
        'protein': 0.5,
        'carbs': 25.0,
        'fat': 0.3,
        'quantity': 2,
      };

      final item = FoodItem.fromJson(json);

      expect(item.name, 'Apple');
      expect(item.calories, 95.0);
      expect(item.protein, 0.5);
      expect(item.carbs, 25.0);
      expect(item.fat, 0.3);
      expect(item.quantity, 2);
    });

    test('fromJson uses "description" as fallback for name', () {
      final json = {
        'description': 'Banana',
        'calories': 105.0,
        'protein': 1.3,
        'carbs': 27.0,
        'fat': 0.4,
        'quantity': 1,
      };

      final item = FoodItem.fromJson(json);
      expect(item.name, 'Banana');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final item = FoodItem.fromJson(json);

      expect(item.name, '');
      expect(item.calories, 0.0);
      expect(item.protein, 0.0);
      expect(item.carbs, 0.0);
      expect(item.fat, 0.0);
      expect(item.quantity, 1);
    });

    test('toJson produces correct map', () {
      final item = FoodItem(
        name: 'Rice',
        calories: 200.0,
        protein: 4.0,
        carbs: 45.0,
        fat: 0.5,
        quantity: 1,
      );

      final json = item.toJson();

      expect(json['name'], 'Rice');
      expect(json['calories'], 200.0);
      expect(json['protein'], 4.0);
      expect(json['carbs'], 45.0);
      expect(json['fat'], 0.5);
      expect(json['quantity'], 1);
    });

    test('toJson → fromJson round-trip preserves data', () {
      final original = FoodItem(
        name: 'Chicken Breast',
        calories: 165.0,
        protein: 31.0,
        carbs: 0.0,
        fat: 3.6,
        quantity: 1,
      );

      final restored = FoodItem.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.calories, original.calories);
      expect(restored.protein, original.protein);
      expect(restored.carbs, original.carbs);
      expect(restored.fat, original.fat);
      expect(restored.quantity, original.quantity);
    });
  });

  group('MealsData', () {
    test('fromJson parses all meal lists', () {
      final json = {
        'breakfast': [
          {'name': 'Oats', 'calories': 150, 'protein': 5, 'carbs': 27, 'fat': 3, 'quantity': 1}
        ],
        'lunch': [
          {'name': 'Salad', 'calories': 120, 'protein': 3, 'carbs': 10, 'fat': 7, 'quantity': 1}
        ],
        'dinner': [],
      };

      final meals = MealsData.fromJson(json);

      expect(meals.breakfast.length, 1);
      expect(meals.breakfast.first.name, 'Oats');
      expect(meals.lunch.length, 1);
      expect(meals.lunch.first.name, 'Salad');
      expect(meals.dinner.length, 0);
    });

    test('fromJson handles missing lists with empty defaults', () {
      final meals = MealsData.fromJson({});

      expect(meals.breakfast, isEmpty);
      expect(meals.lunch, isEmpty);
      expect(meals.dinner, isEmpty);
    });

    test('copyWith replaces only specified meals', () {
      final original = MealsData(breakfast: [], lunch: [], dinner: []);
      final newBreakfast = [
        FoodItem(name: 'Egg', calories: 70, protein: 6, carbs: 1, fat: 5, quantity: 2),
      ];

      final updated = original.copyWith(breakfast: newBreakfast);

      expect(updated.breakfast.length, 1);
      expect(updated.breakfast.first.name, 'Egg');
      expect(updated.lunch, isEmpty);
      expect(updated.dinner, isEmpty);
    });

    test('toJson → fromJson round-trip preserves structure', () {
      final original = MealsData(
        breakfast: [FoodItem(name: 'Toast', calories: 80, protein: 2, carbs: 15, fat: 1, quantity: 1)],
        lunch: [],
        dinner: [FoodItem(name: 'Pasta', calories: 300, protein: 10, carbs: 50, fat: 8, quantity: 1)],
      );

      final restored = MealsData.fromJson(original.toJson());

      expect(restored.breakfast.length, 1);
      expect(restored.breakfast.first.name, 'Toast');
      expect(restored.lunch, isEmpty);
      expect(restored.dinner.length, 1);
      expect(restored.dinner.first.name, 'Pasta');
    });
  });
}
