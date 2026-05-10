# KixFit — Project Overview

## 🎯 Mission
KixFit is a premium AI-powered fitness and nutrition tracking app for Android & iOS.  
Users simply speak or type what they ate, and KixFit's AI instantly breaks down every nutritional value, tracks daily intake, and delivers smart insights to help them reach their goals.

## 📱 Platform
- **Flutter** (Android + iOS)
- **Firebase** (Auth, Firestore, Storage, Cloud Functions)
- **OpenAI GPT-4o** (food analysis AI)
- **State Management:** Riverpod 2.x

## 🧩 Core Features
| # | Feature | Status |
|---|---------|--------|
| 1 | Onboarding (age, weight, goal) | 🟡 In Progress |
| 2 | Firebase Auth (email + Google) | 🟡 In Progress |
| 3 | AI Food Parser (voice + text) | 🟡 In Progress |
| 4 | Daily Dashboard with macros | 🟡 In Progress |
| 5 | Meal history & reports | ⬜ Planned |
| 6 | Weight progress tracking | ⬜ Planned |
| 7 | AI insights & comments | ⬜ Planned |
| 8 | Push notifications | ⬜ Planned |

## 🎨 Design Philosophy
- **Dark mode first** — deep backgrounds, neon accents
- **Glassmorphism** — frosted glass cards
- **Big numbers** — calories front and center
- **Micro-animations** — everything breathes
- **Space Grotesk** font — modern, geometric

## 🔒 Security
- API keys stored server-side via Firebase Cloud Functions
- No sensitive data in client-side code
- `flutter_secure_storage` for local tokens

## 📁 Repository Structure
```
lib/
├── core/           # Theme, constants, utilities, error handling
├── features/       # Feature-based modules (auth, dashboard, food_tracking...)
├── shared/         # Reusable widgets and providers
├── services/       # AI and Firebase service layers
assets/             # Fonts, images, animations, icons
docs/               # This documentation
```

## 🚀 Getting Started
```bash
flutter pub get
flutter run
```

> Set your Firebase project in `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).  
> Set your OpenAI API key via Firebase Remote Config or Cloud Functions.
