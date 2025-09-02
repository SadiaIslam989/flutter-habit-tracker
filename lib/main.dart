import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:habit_tracker/auth/auth_wrapper.dart';
import 'firebase_options.dart';
import 'settings/settings_screen.dart';
import 'theme/theme_provider.dart';
import 'quotes/quotes_provider.dart';

import 'auth/login_screen.dart';
import 'auth/auth_provider.dart';
import 'home/home_screen.dart';
import 'profile/profileViewScreen.dart';
import 'profile/edit_profile_screen.dart';
import 'auth/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => QuotesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Habit Tracker',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/home': (_) => const HomeScreen(),
            '/profile-view': (_) => const ProfileViewScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/edit-profile') {
              final args =
                  (settings.arguments as Map?)?.cast<String, dynamic>() ?? {};
              return MaterialPageRoute(
                builder: (_) => EditProfileScreen(profileData: args),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
