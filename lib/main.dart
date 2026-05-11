import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/food_tracking/presentation/screens/food_entry_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/profile_setup_screen.dart';
import 'features/auth/presentation/screens/profile_screen.dart';
import 'features/statistics/presentation/screens/stats_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/data/repositories/profile_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize date formatting for local language
  await initializeDateFormatting('hr', null);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    const ProviderScope(
      child: KixFitApp(),
    ),
  );
}

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final authValue = authState.value;
      final isLoggedIn = authValue != null;
      
      // Definiramo rute koje su dostupne bez prijave
      final isAuthRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/onboarding' || 
                          state.matchedLocation == '/register';

      // 1. Ako nije prijavljen i nije na auth ruti -> idi na login
      if (!isLoggedIn) {
        if (isAuthRoute) return null;
        return '/login';
      }
      
      // 2. Ako je prijavljen, provjeri profil
      final profileAsync = ref.read(userProfileProvider);
      
      return profileAsync.when(
        data: (profile) {
          // Ako nema profila, mora ga postaviti (osim ako je već na setupu)
          if (profile == null) {
            if (state.matchedLocation == '/profile-setup') return null;
            return '/profile-setup';
          }
          
          // Ako ima profil i pokušava ići na login/onboarding -> baci ga na dashboard
          if (isAuthRoute) {
            return '/dashboard';
          }
          
          return null;
        },
        // Dok se profil učitava, ostani gdje jesi (ili dashboard ako smo tek ušli)
        loading: () => null,
        error: (_, __) => '/login',
      );
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/profile-setup', builder: (context, state) => const ProfileSetupScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/food-entry', builder: (context, state) => const FoodEntryScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
    ],
  );
});

class KixFitApp extends ConsumerWidget {
  const KixFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'KixFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
