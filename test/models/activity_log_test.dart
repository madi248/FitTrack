import 'package:flutter_test/flutter_test.dart';
import 'package:fit_track_mobile/models/activity_log.dart';

void main() {
  group('ActivityLog', () {
    test('fromJson creates instance with correct values', () {
      final json = {
        'type': 'running',
        'duration': 30,
        'caloriesBurned': 250,
        'timestamp': '2026-01-15T10:30:00.000',
      };

      final log = ActivityLog.fromJson(json);

      expect(log.type, ActivityType.running);
      expect(log.duration, 30);
      expect(log.caloriesBurned, 250);
      expect(log.timestamp, DateTime.parse('2026-01-15T10:30:00.000'));
    });

    test('fromJson defaults unknown type to walking', () {
      final json = {
        'type': 'swimming',
        'duration': 45,
        'caloriesBurned': 300,
        'timestamp': '2026-01-15T10:30:00.000',
      };

      final log = ActivityLog.fromJson(json);
      expect(log.type, ActivityType.walking);
    });

    test('fromJson handles missing duration and calories with 0', () {
      final json = {
        'type': 'cycling',
        'timestamp': '2026-01-15T10:30:00.000',
      };

      final log = ActivityLog.fromJson(json);

      expect(log.duration, 0);
      expect(log.caloriesBurned, 0);
    });

    test('toJson produces correct map', () {
      final timestamp = DateTime(2026, 1, 15, 10, 30);
      final log = ActivityLog(
        type: ActivityType.cycling,
        duration: 60,
        caloriesBurned: 400,
        timestamp: timestamp,
      );

      final json = log.toJson();

      expect(json['type'], 'cycling');
      expect(json['duration'], 60);
      expect(json['caloriesBurned'], 400);
      expect(json['timestamp'], timestamp.toIso8601String());
    });

    test('toJson → fromJson round-trip preserves data', () {
      final original = ActivityLog(
        type: ActivityType.walking,
        duration: 20,
        caloriesBurned: 100,
        timestamp: DateTime(2026, 2, 1, 8, 0),
      );

      final restored = ActivityLog.fromJson(original.toJson());

      expect(restored.type, original.type);
      expect(restored.duration, original.duration);
      expect(restored.caloriesBurned, original.caloriesBurned);
      expect(restored.timestamp, original.timestamp);
    });

    test('activityName returns correct display name', () {
      expect(
        ActivityLog(type: ActivityType.walking, duration: 0, caloriesBurned: 0, timestamp: DateTime.now()).activityName,
        'Walking',
      );
      expect(
        ActivityLog(type: ActivityType.running, duration: 0, caloriesBurned: 0, timestamp: DateTime.now()).activityName,
        'Running',
      );
      expect(
        ActivityLog(type: ActivityType.cycling, duration: 0, caloriesBurned: 0, timestamp: DateTime.now()).activityName,
        'Cycling',
      );
    });

    test('durationMinutes getter returns duration', () {
      final log = ActivityLog(
        type: ActivityType.running,
        duration: 45,
        caloriesBurned: 350,
        timestamp: DateTime.now(),
      );

      expect(log.durationMinutes, 45);
    });
  });
}
