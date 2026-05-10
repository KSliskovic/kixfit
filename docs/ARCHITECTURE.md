# KixFit — Architecture

## Overview
KixFit follows a **Feature-First Clean Architecture** with clear separation of concerns across three layers per feature.

```
Presentation → Domain → Data
```

## Layers

### 1. Presentation Layer
- Flutter Widgets (Screens + smaller Widgets)
- Riverpod `StateNotifier` / `AsyncNotifier` providers
- No business logic — only UI state and user interactions

### 2. Domain Layer
- **Entities** — Pure Dart models (no framework dependencies)
- **Repository Interfaces** — Abstract contracts
- **Use Cases** — Single-responsibility business operations

### 3. Data Layer
- **Repository Implementations** — Concrete implementations of domain interfaces
- **Data Sources** — Firebase, OpenAI API, local cache
- **Data Models** — JSON-serializable versions of entities (using `freezed`)

## State Management: Riverpod 2.x
```
Provider → StateProvider → NotifierProvider → AsyncNotifierProvider
```
- Each feature has its own providers file
- `ref.watch` for reactive UI
- `ref.read` for one-time reads in callbacks

## Navigation: GoRouter
```
/ → Splash
/onboarding → OnboardingScreen
/auth/login → LoginScreen
/auth/register → RegisterScreen
/home → DashboardScreen (shell route)
  /home/food → FoodEntryScreen
  /home/reports → ReportsScreen
  /home/profile → ProfileScreen
/weight → WeightTrackingScreen
```

## AI Service Layer
```
UserInput (text/voice)
    ↓
AIService.parseFood(input)
    ↓
Firebase Cloud Function (secure API call)
    ↓
OpenAI GPT-4o (JSON response)
    ↓
NutritionEntry model
    ↓
Firestore
```

## Firebase Structure (Firestore)
```
users/{uid}
  ├── profile: { name, age, weight, height, goal, targetCalories }
  ├── meals/{mealId}: { timestamp, description, items[], totals{} }
  └── weightLog/{entryId}: { date, weight }
```

## Error Handling
- Custom `Failure` sealed class
- `Either<Failure, T>` return types in use cases
- UI shows friendly error states via `AsyncValue`
