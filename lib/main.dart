import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'logic/app_state.dart';
import 'logic/settings_provider.dart';
import 'logic/reader_controller.dart';
import 'logic/library_provider.dart';
import 'logic/download_controller.dart';
import 'services/config_service.dart';
import 'services/analytics_service.dart'; // Restored
import 'ui/main_screen.dart';
import 'ui/auth/login_page.dart';
import 'ui/auth/acknowledgement_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // --- Restored Analytics & Remote Config ---
  final analytics = AnalyticsService();
  await analytics.initializeUser();
  await ConfigService.fetchRemoteConfig();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ReaderController()),
        ChangeNotifierProvider(create: (_) => DownloadController()), 
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1C),
        primaryColor: Colors.blueAccent,
        cardColor: const Color(0xFF161D2D),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Loading state for Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // 2. If user is NOT logged in, show Login Screen
          if (!snapshot.hasData) {
            return const LoginPage();
          }

          // 3. If user IS logged in, check if they need to see Acknowledgement
          return FutureBuilder<bool>(
            future: AppState.isFirstRun(),
            builder: (context, firstRunSnapshot) {
              if (!firstRunSnapshot.hasData) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              if (firstRunSnapshot.data == true) {
                return const AcknowledgementPage();
              }

              // 4. Everything is ready, show Main Screen
              return const MainScreen();
            },
          );
        },
      ),
    );
  }
}