import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/food_item.dart';
import '../models/activity_log.dart';
import '../models/daily_goals.dart';

class ApiService {
  static const String projectId = 'fbyuyoqgyqwcsdtgewoq';
  static const String publicAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZieXV5b3FneXF3Y3NkdGdld29xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3NzE1OTgsImV4cCI6MjA4MzM0NzU5OH0.MkqnuWmT9O5h6y50dHd98FFIxEV26LhBpeqfoAAcOs8';
  
  static const String functionName = 'make-server-a4effe24';

  Future<Map<String, dynamic>> _apiCall(
    String endpoint, {
    Map<String, dynamic>? body,
    String method = 'GET',
  }) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken ?? publicAnonKey;

      final response = await Supabase.instance.client.functions.invoke(
        functionName,
        body: {
          'endpoint': endpoint,
          'method': method,
          'body': body,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.status == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('API request failed: ${response.status}');
      }
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }

  // Auth API
  Future<Map<String, dynamic>> signUp(
      String email, String password, String name) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user == null) {
        throw Exception('Sign up failed');
      }
      
      return {'success': true, 'user': response.user?.toJson()};
    } catch (e) {
      if (e is AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Sign up failed: $e');
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Login failed');
      }
      
      return {
        'success': true,
        'user': response.user!.toJson(),
      };
    } catch (e) {
      if (e is AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      if (e is AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Reset password failed: $e');
    }
  }

  Future<Map<String, dynamic>> getSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.user != null) {
      return {
        'success': true,
        'user': session.user.toJson(),
      };
    }
    return {'success': false};
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  // Google Sign In
  Future<Map<String, dynamic>> googleSignIn() async {
    try {
      /// Web Client ID that you registered with Google Cloud.
      const webClientId = '636557276818-sljlvja3s3d8jtfr4ac49tocfm53puc7.apps.googleusercontent.com';

      /// iOS Client ID that you registered with Google Cloud.
      /// For Android, this can be null.
      const String? iosClientId = null;

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final accessToken = googleAuth?.accessToken;
      final idToken = googleAuth?.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

       if (response.user == null) {
        throw Exception('Google Sign in failed');
      }

      return {
        'success': true,
        'user': response.user!.toJson(),
      };
    } catch (e) {
      throw Exception('Google Sign in failed: $e');
    }
  }

  // Goals API
  Future<DailyGoals> getGoals() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final data = await Supabase.instance.client
          .from('daily_goals')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (data == null) {
        // Return default goals if none exist
        return DailyGoals(
          calories: 2000,
          caloriesToBurn: 500,
          protein: 150,
          carbs: 200,
          fat: 67,
        );
      }
      
      return DailyGoals.fromJson(data);
    } catch (e) {
      print('Error getting goals: $e');
      // Return defaults on error to keep app usable
      return DailyGoals(
        calories: 2000,
        caloriesToBurn: 500,
        protein: 150,
        carbs: 200,
        fat: 67,
      );
    }
  }

  Future<DailyGoals> saveGoals(DailyGoals goals) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final goalsJson = goals.toJson();
      goalsJson['user_id'] = user.id;
      goalsJson['updated_at'] = DateTime.now().toIso8601String();

      final data = await Supabase.instance.client
          .from('daily_goals')
          .upsert(goalsJson)
          .select()
          .single();
          
      return DailyGoals.fromJson(data);
    } catch (e) {
      throw Exception('Failed to save goals: $e');
    }
  }

  // Meals API
  Future<MealsData> getMeals(String date) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final data = await Supabase.instance.client
          .from('meals')
          .select()
          .eq('user_id', user.id)
          .eq('date', date)
          .maybeSingle();

      if (data == null) {
        return MealsData(breakfast: [], lunch: [], dinner: []);
      }
      
      return MealsData.fromJson(data);
    } catch (e) {
      print('Error getting meals: $e');
      return MealsData(breakfast: [], lunch: [], dinner: []);
    }
  }

  Future<MealsData> saveMeals(String date, MealsData meals) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final mealsJson = meals.toJson();
      mealsJson['user_id'] = user.id;
      mealsJson['date'] = date;
      mealsJson['updated_at'] = DateTime.now().toIso8601String();

      final data = await Supabase.instance.client
          .from('meals')
          .upsert(mealsJson, onConflict: 'user_id, date')
          .select()
          .single();
          
      return MealsData.fromJson(data);
    } catch (e) {
      throw Exception('Failed to save meals: $e');
    }
  }

  // Activities API
  Future<List<ActivityLog>> getActivities(String date) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final data = await Supabase.instance.client
          .from('activities')
          .select()
          .eq('user_id', user.id)
          .eq('date', date)
          .maybeSingle();

      if (data == null || data['activities'] == null) {
        return [];
      }

      final activitiesList = data['activities'] as List<dynamic>;
      return activitiesList
          .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting activities: $e');
      return [];
    }
  }

  Future<List<ActivityLog>> saveActivities(
      String date, List<ActivityLog> activities) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final activitiesJson = activities.map((e) => e.toJson()).toList();
      
      final data = await Supabase.instance.client
          .from('activities')
          .upsert({
            'user_id': user.id,
            'date': date,
            'activities': activitiesJson,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id, date')
          .select()
          .single();

      final savedList = data['activities'] as List<dynamic>;
      return savedList
          .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to save activities: $e');
    }
  }

  // Profile API
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (data == null) {
        return {
          'id': user.id,
          'email': user.email,
          'name': user.userMetadata?['name'] ?? '',
        };
      }
      
      // Inject email from auth since it's not in the profiles table
      final profileWithEmail = Map<String, dynamic>.from(data);
      profileWithEmail['email'] = user.email;
      
      return profileWithEmail;
    } catch (e) {
      print('Error getting profile: $e');
      return {};
    }
  }

  Future<String> uploadAvatar(File file) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final fileExt = file.path.split('.').last;
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      try {
        await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
      } catch (e) {
        // If upload fails, try creating the bucket first (just in case, though SQL should handle it)
        // Ignoring specific error handling for brevity, assuming bucket exists or SQL was run.
        rethrow;
      }

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);
          
      // Update profile with new avatar URL
      await Supabase.instance.client
          .from('profiles')
          .upsert({
            'id': user.id,
            'avatar_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          });
          
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<Map<String, dynamic>> saveProfile(
      Map<String, dynamic> profile) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final updates = Map<String, dynamic>.from(profile);
      updates['id'] = user.id;
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      // Remove campos que no existen en la tabla para evitar errores
      updates.remove('email'); 
      
      final data = await Supabase.instance.client
          .from('profiles')
          .upsert(updates)
          .select()
          .single();
          
      return data;
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  Future<void> submitFeedback(String message) async {
     final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      await Supabase.instance.client.from('feedback').insert({
        'user_id': user.id,
        'message': message,
      });
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  // USDA API Configuration
  static const String _usdaApiKey = 'bwKmBrqYh7qTpPhN7or7PW2EiXa4oUdTKrUCNHl2';
  static const String _usdaBaseUrl = 'https://api.nal.usda.gov/fdc/v1';

  // Food Search API - Direct USDA API Integration
  Future<List<FoodItem>> searchFood(String query, {int pageSize = 15}) async {
    if (query.trim().isEmpty || query.trim().length < 2) {
      return [];
    }

    try {
      final url = Uri.parse(
        '$_usdaBaseUrl/foods/search?query=${Uri.encodeComponent(query)}&pageSize=$pageSize&api_key=$_usdaApiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final foods = data['foods'] as List<dynamic>? ?? [];

        return foods
            .map((food) => _transformUSDAFood(food as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('USDA API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Food search failed: $e');
    }
  }

  // Transform USDA food data to our app's format
  FoodItem _transformUSDAFood(Map<String, dynamic> food) {
    final nutrients = food['foodNutrients'] as List<dynamic>? ?? [];

    // Helper function to find nutrient value by name or number
    double findNutrient(List<String> names, List<String> numbers) {
      try {
        final nutrient = nutrients.firstWhere(
          (n) {
            final nutrientMap = n as Map<String, dynamic>;
            final nutrientName = (nutrientMap['nutrientName'] as String? ?? '').toLowerCase();
            final nutrientNumber = nutrientMap['nutrientNumber'] as String? ?? '';
            return names.any((name) => nutrientName.contains(name.toLowerCase())) ||
                numbers.contains(nutrientNumber);
          },
        );

        final nutrientMap = nutrient as Map<String, dynamic>;
        final value = (nutrientMap['value'] as num?)?.toDouble() ?? 0.0;
        return (value * 10).round() / 10;
      } catch (e) {
        return 0.0;
      }
    }

    // Extract nutrition values (per 100g by default in USDA data)
    final calories = findNutrient(['energy'], ['208']);
    final protein = findNutrient(['protein'], ['203']);
    final carbs = findNutrient(['carbohydrate'], ['205']);
    final fat = findNutrient(['total lipid', 'fat'], ['204']);

    return FoodItem(
      name: food['description'] as String? ?? '',
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      quantity: 1,
    );
  }

  // Helper
  static String getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
