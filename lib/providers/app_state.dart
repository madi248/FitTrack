import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/activity_log.dart';
import '../models/daily_goals.dart';
import '../services/api_service.dart';
import '../services/health_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final HealthService _healthService = HealthService();

  // User state
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;
  bool _loading = true;

  // Data state
  MealsData _meals = MealsData(breakfast: [], lunch: [], dinner: []);
  List<ActivityLog> _activities = [];
  
  // Health Data
  int _steps = 0;
  double _autoBurnedCalories = 0.0;
  
  DailyGoals _dailyGoals = DailyGoals(
    calories: 2000,
    caloriesToBurn: 500,
    protein: 150,
    carbs: 200,
    fat: 67,
  );

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get loading => _loading;
  MealsData get meals => _meals;
  List<ActivityLog> get activities => _activities;
  int get steps => _steps;
  double get autoBurnedCalories => _autoBurnedCalories;
  DailyGoals get dailyGoals => _dailyGoals;

  // Initialize app
  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    try {
      final session = await _apiService.getSession();
      if (session['success'] == true && session['user'] != null) {
        _currentUser = session['user'] as Map<String, dynamic>;
        _isLoggedIn = true;
        await loadUserData();
      }
    } catch (e) {
      // No active session
      _isLoggedIn = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      final today = ApiService.getTodayDate();
      _dailyGoals = await _apiService.getGoals();
      _meals = await _apiService.getMeals(today);
      _activities = await _apiService.getActivities(today);
      // Don't await strictly to not block UI
      fetchHealthData();
      notifyListeners();
    } catch (e) {
      // Use defaults on error
    }
  }

  // Auth methods
  Future<void> login(String email, String password) async {
    try {
      final data = await _apiService.signIn(email, password);
      if (data['success'] == true && data['user'] != null) {
        _currentUser = data['user'] as Map<String, dynamic>;
        _isLoggedIn = true;
        await loadUserData();
        notifyListeners();
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      final data = await _apiService.signUp(email, password, name);
      if (data['success'] == true) {
        // Auto login after signup
        await login(email, password);
      } else {
        throw Exception('Sign up failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    _meals = MealsData(breakfast: [], lunch: [], dinner: []);
    _activities = [];
    _dailyGoals = DailyGoals(
      calories: 2000,
      caloriesToBurn: 500,
      protein: 150,
      carbs: 200,
      fat: 67,
    );
    notifyListeners();
  }

  // Google Login
  Future<void> googleLogin() async {
    try {
      final data = await _apiService.googleSignIn();
      if (data['success'] == true && data['user'] != null) {
        _currentUser = data['user'] as Map<String, dynamic>;
        _isLoggedIn = true;
        await loadUserData();
        notifyListeners();
      } else {
        throw Exception('Google Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Food methods
  Future<void> addFood(FoodItem food, String mealType) async {
    final updatedMeals = _meals.copyWith(
      breakfast: mealType == 'breakfast'
          ? [..._meals.breakfast, food]
          : _meals.breakfast,
      lunch: mealType == 'lunch'
          ? [..._meals.lunch, food]
          : _meals.lunch,
      dinner: mealType == 'dinner'
          ? [..._meals.dinner, food]
          : _meals.dinner,
    );

    _meals = updatedMeals;
    notifyListeners();

    try {
      final today = ApiService.getTodayDate();
      await _apiService.saveMeals(today, updatedMeals);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeFood(FoodItem food, String mealType) async {
    List<FoodItem> currentList;
    switch (mealType) {
      case 'breakfast':
        currentList = [..._meals.breakfast];
        break;
      case 'lunch':
        currentList = [..._meals.lunch];
        break;
      case 'dinner':
        currentList = [..._meals.dinner];
        break;
      default:
        return;
    }

    // Remove the first instance of this food
    // We use index to be safe if there are identical items
    final index = currentList.indexOf(food);
    if (index != -1) {
      currentList.removeAt(index);
    } else {
      // Fallback if object identity fails (though provider keeps same instances usually)
      // Try finding by properties
       final fallbackIndex = currentList.indexWhere((f) => f.name == food.name && f.calories == food.calories);
       if (fallbackIndex != -1) {
         currentList.removeAt(fallbackIndex);
       }
    }

    final updatedMeals = _meals.copyWith(
      breakfast: mealType == 'breakfast' ? currentList : _meals.breakfast,
      lunch: mealType == 'lunch' ? currentList : _meals.lunch,
      dinner: mealType == 'dinner' ? currentList : _meals.dinner,
    );

    _meals = updatedMeals;
    notifyListeners();

    try {
      final today = ApiService.getTodayDate();
      await _apiService.saveMeals(today, updatedMeals);
    } catch (e) {
      print('Error removing food: $e');
      // Optionally revert state on error
    }
  }

  // Activity methods
  Future<void> addActivity(ActivityLog activity) async {
    _activities = [..._activities, activity];
    notifyListeners();

    try {
      final today = ApiService.getTodayDate();
      await _apiService.saveActivities(today, _activities);
    } catch (e) {
      // Handle error
    }
  }

  // Goals methods
  Future<void> saveGoals(DailyGoals goals) async {
    _dailyGoals = goals;
    notifyListeners();

    try {
      await _apiService.saveGoals(goals);
    } catch (e) {
      // Handle error
    }
  }

  // Avatar methods
  Future<void> updateAvatar(File file) async {
    try {
      final url = await _apiService.uploadAvatar(file);
      
      // Update local state
      if (_currentUser != null) {
        // Create new map to ensure UI update
        final updatedUser = Map<String, dynamic>.from(_currentUser!);
        // We might be storing profile data in _currentUser or fetching it separately.
        // Assuming _currentUser gets updated or we need to update the profile fetch
        // Let's reload profile data to be safe, or direct update
      }
      
      // Since we updated the profile directly in uploadAvatar, let's refresh the profile data
      await _refreshProfile();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> _refreshProfile() async {
    try {
      final profile = await _apiService.getProfile();
      // Update relevant parts of state if needed, or if we rely on _currentUser
      // Actually AppState doesn't seem to hold a separate _profile map, 
      // it uses _currentUser for auth info and loads specific data (goals, meals).
      // But ProfilePage loads profile independently. 
      // HomePage might need a way to see this.
      
      // Let's store profile data in _currentUser or a new field if strictly needed
      // For now, let's assume we merge it into _currentUser or provide a way to access it
      if (_currentUser != null) {
        _currentUser = {..._currentUser!, ...profile};
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing profile: $e');
    }
  }

  // Health methods
  Future<void> requestHealthPermissions() async {
    await _healthService.requestPermissions();
    await fetchHealthData();
  }

  Future<void> fetchHealthData() async {
    try {
      final steps = await _healthService.fetchSteps();
      final calories = await _healthService.fetchActiveCalories();
      
      _steps = steps;
      _autoBurnedCalories = calories;
      notifyListeners();
    } catch (e) {
      print("Error fetching health data: $e");
    }
  }
}
