import 'package:flutter_test/flutter_test.dart';
import 'package:fit_track_mobile/models/daily_goals.dart';

void main() {
  group('DailyGoals', () {
    test('fromJson creates instance with correct values', () {
      final json = {
        'calories': 2500,
        'caloriesToBurn': 600,
        'protein': 180,
        'carbs': 250,
        'fat': 80,
      };

      final goals = DailyGoals.fromJson(json);

      expect(goals.calories, 2500);
      expect(goals.caloriesToBurn, 600);
      expect(goals.protein, 180);
      expect(goals.carbs, 250);
      expect(goals.fat, 80);
    });

    test('fromJson uses default values when fields are missing', () {
      final goals = DailyGoals.fromJson({});

      expect(goals.calories, 2000);
      expect(goals.caloriesToBurn, 500);
      expect(goals.protein, 150);
      expect(goals.carbs, 200);
      expect(goals.fat, 67);
    });

    test('toJson produces correct map', () {
      final goals = DailyGoals(
        calories: 1800,
        caloriesToBurn: 400,
        protein: 120,
        carbs: 180,
        fat: 60,
      );

      final json = goals.toJson();

      expect(json['calories'], 1800);
      expect(json['caloriesToBurn'], 400);
      expect(json['protein'], 120);
      expect(json['carbs'], 180);
      expect(json['fat'], 60);
    });

    test('toJson → fromJson round-trip preserves data', () {
      final original = DailyGoals(
        calories: 2200,
        caloriesToBurn: 550,
        protein: 160,
        carbs: 220,
        fat: 70,
      );

      final restored = DailyGoals.fromJson(original.toJson());

      expect(restored.calories, original.calories);
      expect(restored.caloriesToBurn, original.caloriesToBurn);
      expect(restored.protein, original.protein);
      expect(restored.carbs, original.carbs);
      expect(restored.fat, original.fat);
    });

    test('copyWith replaces only specified fields', () {
      final original = DailyGoals(
        calories: 2000,
        caloriesToBurn: 500,
        protein: 150,
        carbs: 200,
        fat: 67,
      );

      final updated = original.copyWith(calories: 2500, protein: 180);

      expect(updated.calories, 2500);
      expect(updated.protein, 180);
      // Unchanged fields
      expect(updated.caloriesToBurn, 500);
      expect(updated.carbs, 200);
      expect(updated.fat, 67);
    });
  });
}
