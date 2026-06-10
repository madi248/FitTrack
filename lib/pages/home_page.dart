import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/bottom_nav.dart';
import 'food_log_main_page.dart';
import 'summary_page.dart';
import 'activity_page.dart';
import 'stopwatch_page.dart';
import 'settings_page.dart';
import 'add_food_page.dart';
import 'add_activity_page.dart';
import 'profile_page.dart';
import 'goals_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentPage = 'home';
  String? _selectedMeal;
  String? _selectedActivity;

  void _navigateTo(String page, {String? meal, String? activity}) {
    setState(() {
      _currentPage = page;
      if (meal != null) _selectedMeal = meal;
      if (activity != null) _selectedActivity = activity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    Widget currentPageWidget;

    switch (_currentPage) {
      case 'home':
        currentPageWidget = FoodLogMainPage(
          navigateTo: _navigateTo,
          meals: appState.meals,
          dailyGoals: appState.dailyGoals,
        );
        break;
      case 'summary':
        currentPageWidget = SummaryPage(
          navigateTo: _navigateTo,
          meals: appState.meals,
          dailyGoals: appState.dailyGoals,
        );
        break;
      case 'activity':
        currentPageWidget = ActivityPage(
          navigateTo: _navigateTo,
        );
        break;
      case 'stopwatch':
        currentPageWidget = StopwatchPage(navigateTo: _navigateTo);
        break;
      case 'settings':
        currentPageWidget = SettingsPage(
          navigateTo: _navigateTo,
          onLogout: () async {
            await appState.logout();
          },
        );
        break;
      case 'addfood':
        currentPageWidget = AddFoodPage(
          onBack: () => _navigateTo('home'),
          selectedMeal: _selectedMeal,
          onAddFood: (food, mealType) async {
            await appState.addFood(food, mealType);
            _navigateTo('home');
          },
        );
        break;
      case 'addactivity':
        currentPageWidget = AddActivityPage(
          onBack: () => _navigateTo('activity'),
          selectedActivity: _selectedActivity,
          onAddActivity: (activity) async {
            await appState.addActivity(activity);
            _navigateTo('activity');
          },
        );
        break;
      case 'profile':
        currentPageWidget = ProfilePage(
          onBack: () => _navigateTo('settings'),
          currentUser: appState.currentUser,
        );
        break;
      case 'goals':
        currentPageWidget = GoalsPage(
          onBack: () => _navigateTo('settings'),
          currentGoals: appState.dailyGoals,
          onSaveGoals: (goals) async {
            await appState.saveGoals(goals);
          },
        );
        break;
      default:
        currentPageWidget = FoodLogMainPage(
          navigateTo: _navigateTo,
          meals: appState.meals,
          dailyGoals: appState.dailyGoals,
        );
    }

    return Scaffold(
      body: Stack(
        children: [
          currentPageWidget,
          if (_currentPage != 'addfood' &&
              _currentPage != 'addactivity' &&
              _currentPage != 'profile' &&
              _currentPage != 'goals')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNav(
                currentPage: _currentPage,
                onNavigate: _navigateTo,
              ),
            ),
        ],
      ),
    );
  }
}
