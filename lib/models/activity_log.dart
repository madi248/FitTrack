enum ActivityType { walking, running, cycling }

class ActivityLog {
  final ActivityType type;
  final int duration; // in minutes
  final int caloriesBurned;
  final DateTime timestamp;

  ActivityLog({
    required this.type,
    required this.duration,
    required this.caloriesBurned,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ActivityType.walking,
      ),
      duration: json['duration'] as int? ?? 0,
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  // Helpers
  String get activityName {
    switch (type) {
      case ActivityType.walking:
        return 'Walking';
      case ActivityType.running:
        return 'Running';
      case ActivityType.cycling:
        return 'Cycling';
    }
  }

  int get durationMinutes => duration;
}
