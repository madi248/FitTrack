import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  final Health _health = Health();

  // Define the types of data we want to fetch
  static const List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  // Request authorization
  Future<bool> requestPermissions() async {
    // Request permission to use Health Connect
    await Permission.activityRecognition.request();
    
    // Check if we need to request permissions
    try {
      bool requested = await _health.requestAuthorization(types);
      return requested;
    } catch (e) {
      print("Error requesting health auth: $e");
      return false;
    }
  }

  // Fetch Steps
  Future<int> fetchSteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      print("Error fetching steps: $e");
      return 0;
    }
  }

  // Fetch Active Calories Burned
  Future<double> fetchActiveCalories() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // fetch health data
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );

      // Sum up the values
      double totalCalories = 0.0;
      for (var point in healthData) {
         final value = point.value;
         // V10+ API: value is HealthValue
         if (value is NumericHealthValue) {
           totalCalories += value.numericValue.toDouble();
         }
      }
      
      return totalCalories;
    } catch (e) {
      print("Error fetching calories: $e");
      return 0.0;
    }
  }
}
