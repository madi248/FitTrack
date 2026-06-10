<p align="center">
  <img src="assets/images/app_icon.png" alt="FitTrack Logo" width="120" />
</p>

<h1 align="center">FitTrack</h1>
<p align="center">
  <strong>Your intelligent fitness & nutrition companion — track meals, log workouts, and crush your health goals.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Health_Connect-Integrated-4285F4?logo=google-fit&logoColor=white" alt="Health Connect" />
  <img src="https://img.shields.io/github/license/AliHCode/FitTrack" alt="License" />
  <img src="https://github.com/AliHCode/FitTrack/actions/workflows/flutter-ci.yml/badge.svg" alt="CI" />
</p>

---

## 🧩 The Problem

Most fitness apps are either too complex (overloaded with features nobody uses) or too simple (just a step counter). People who want to **track what they eat alongside what they burn** — without paying a subscription — are left with few good options.

**FitTrack** solves this by combining **meal logging** (powered by the USDA nutrition database), **exercise tracking**, and **automatic calorie detection** via Android Health Connect — all in one clean, free app.

---

## 📸 Screenshots

<!-- 
TO ADD SCREENSHOTS:
1. Take screenshots of your app on a real device or emulator
2. Save them to the screenshots/ folder (create it if needed)
3. Replace the placeholder lines below with:
   <img src="screenshots/login.png" width="200" />
   <img src="screenshots/dashboard.png" width="200" />
   etc.
-->

> **Coming soon** — Screenshots will be added after final UI polish.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend** | Flutter 3.x (Dart) | Cross-platform mobile UI |
| **State Management** | Provider | Reactive state with `ChangeNotifier` |
| **Backend** | Supabase | Auth, PostgreSQL DB, Storage |
| **Nutrition API** | USDA FoodData Central | Accurate calorie & macro data |
| **Health Integration** | Android Health Connect | Auto step & calorie tracking |
| **Auth** | Supabase Auth + Google Sign-In | Email/password & OAuth |

---

## ✨ Features

| Feature | Description |
| :--- | :--- |
| 1. **Authentication** | Email/password signup & login, Google Sign-In, password reset via deep link |
| 2. **Calorie Dashboard** | Real-time calorie ring showing daily intake vs. goal |
| 3. **Meal Logging** | Search the USDA database, log to Breakfast / Lunch / Dinner |
| 4. **Activity Tracking** | Manual exercise logging (Walking, Running, Cycling) |
| 5. **Health Connect** | Automatic step count & active calorie burn from Android sensors |
| 6. **Profile** | BMI calculator, avatar upload, personal details |
| 7. **Goal Setting** | Custom daily targets for calories, protein, carbs, fat |
| 8. **Feedback** | In-app help & support with direct feedback submission |

---

## 🚀 Quick Start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable 3.x)
- Android Studio or VS Code with Flutter extension
- An Android device or emulator (API 26+)

### Installation

```bash
# 1. Clone the repo
git clone https://github.com/AliHCode/FitTrack.git
cd FitTrack

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

> The app connects to a hosted Supabase backend out-of-the-box — no extra setup needed.

### Environment Configuration (Optional)

If you want to use your **own** Supabase project:

1. Create a project at [supabase.com](https://supabase.com)
2. Run `schema.sql` in the Supabase SQL Editor
3. Update these values in `lib/services/api_service.dart`:
   ```dart
   static const String projectId = 'YOUR_PROJECT_ID';
   static const String publicAnonKey = 'YOUR_ANON_KEY';
   ```
4. Configure Google OAuth in Supabase Dashboard → Auth → Providers

---

## 📖 How to Use

1. **Sign Up** → Create an account with email or Google
2. **Set Goals** → Go to Profile → set your daily calorie & macro targets
3. **Log Meals** → Tap the search bar on the dashboard → search any food → add to a meal
4. **Log Exercise** → Go to Activity tab → tap the **+** button → choose activity type
5. **Track Progress** → Watch your calorie ring fill up throughout the day
6. **Sync Health Data** → Activity tab → "Auto Data" tab shows steps & burned calories from Health Connect

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point & routing
├── models/
│   ├── food_item.dart         # FoodItem & MealsData models
│   ├── daily_goals.dart       # DailyGoals model
│   └── activity_log.dart      # ActivityLog model & enum
├── pages/
│   ├── login_page.dart        # Login screen
│   ├── signup_page.dart       # Registration screen
│   ├── home_page.dart         # Main container with nav
│   ├── food_log_main_page.dart# Dashboard with calorie ring
│   ├── add_food_page.dart     # USDA food search
│   ├── activity_page.dart     # Manual + Auto activity tabs
│   ├── add_activity_page.dart # Exercise input form
│   ├── profile_page.dart      # User profile & BMI
│   ├── goals_page.dart        # Daily goal settings
│   ├── settings_page.dart     # App settings
│   └── ...
├── providers/
│   └── app_state.dart         # Central state management
├── services/
│   ├── api_service.dart       # Supabase & USDA API calls
│   └── health_service.dart    # Health Connect integration
└── widgets/
    └── bottom_nav.dart        # Custom bottom navigation bar
```

---

## 🧪 Testing

```bash
# Run all unit tests
flutter test

# Run static analysis
flutter analyze
```

Tests cover data model serialization (`FoodItem`, `DailyGoals`, `ActivityLog`), default value handling, and round-trip JSON encoding.

---

## 🗺️ Roadmap

- [x] Core meal & activity logging
- [x] Health Connect auto-tracking
- [x] Google Sign-In
- [x] Profile photo upload
- [ ] 1. Weight trend charts & weekly reports
- [ ] 2. AI-powered food scanning (camera → nutrition)
- [ ] 3. Offline mode with local caching
- [ ] 4. Social challenges & friend leaderboards
- [ ] 5. Barcode scanner for packaged foods

---

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ using Flutter & Supabase
</p>
