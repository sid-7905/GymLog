import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Note: .env file loading: $e");
    dotenv.loadFromString(envString: 'API_BASE_URL=https://gymlogbackend.onrender.com/api');
  }

  runApp(const GymLogApp());
}

class GymLogApp extends StatelessWidget {
  const GymLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'GymLog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background, // #121212
          primaryColor: AppColors.primary, // #B6F36B
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Color(0xFF121212),
            surface: AppColors.surface, // #1E1E1E
            onSurface: AppColors.text, // #FFFFFF
            error: AppColors.error,
          ),
          cardTheme: const CardThemeData(
            color: AppColors.card, // #1E1E1E
            elevation: 0,
            margin: EdgeInsets.zero,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface, // #1E1E1E
            foregroundColor: AppColors.text, // #FFFFFF
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.text),
            bodyMedium: TextStyle(color: AppColors.text),
            titleLarge: TextStyle(color: AppColors.text),
            titleMedium: TextStyle(color: AppColors.text),
          ),
          dividerColor: AppColors.border,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Initial token validation in progress
    if (!authProvider.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: AppColors.primary,
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const MainNavigationScreen();
    }

    return const LoginScreen();
  }
}
