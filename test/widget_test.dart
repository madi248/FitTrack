// Basic smoke test for FitTrack app initialization.
//
// This test verifies the app can be instantiated without errors.
// Model-specific tests are in the test/models/ directory.

import 'package:flutter_test/flutter_test.dart';
import 'package:fit_track_mobile/models/food_item.dart';
import 'package:fit_track_mobile/models/daily_goals.dart';
import 'package:fit_track_mobile/models/activity_log.dart';

void main() {
  test('FoodItem can be created', () {
    final item = FoodItem(
      name: 'Test Food',
      calories: 100,
      protein: 10,
      carbs: 20,
      fat: 5,
      quantity: 1,
    );
    expect(item.name, 'Test Food');
  });

  test('DailyGoals has correct defaults', () {
    final goals = DailyGoals.fromJson({});
    expect(goals.calories, 2000);
  });

  test('ActivityLog supports all activity types', () {
    expect(ActivityType.values.length, 3);
  });
}
