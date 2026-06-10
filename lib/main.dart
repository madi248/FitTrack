import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_state.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/home_page.dart';
import 'pages/reset_password_page.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling
  try {
    await Supabase.initialize(
      url: 'https://${ApiService.projectId}.supabase.co',
      anonKey: ApiService.publicAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
    // Continue anyway - app will work without Supabase for testing
  }

  runApp(const FitTrackApp());
}

class FitTrackApp extends StatefulWidget {
  const FitTrackApp({super.key});

  @override
  State<FitTrackApp> createState() => _FitTrackAppState();
}

class _FitTrackAppState extends State<FitTrackApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: MaterialApp(
        title: 'FitTrack',
        navigatorKey: navigatorKey, // Use global navigator key
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF14B8A6),
            brightness: Brightness.light,
          ),
        ),
        home: const AppNavigator(),
      ),
    );
  }
}

// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (appState.loading) {
          return const LoadingScreen();
        }

        if (!appState.isLoggedIn) {
          return const LoginPage();
        }

        return const HomePage();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF14B8A6),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading FitTrack...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
