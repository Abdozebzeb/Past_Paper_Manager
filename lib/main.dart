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
import 'services/analytics_service.dart';
import 'services/auth_service.dart';
import 'ui/main_screen.dart';
import 'ui/auth/login_page.dart';
import 'ui/auth/acknowledgement_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  
  final bool firstRun = await AppState.isFirstRun();
  if (firstRun) {
    
    
    await AuthService().signOut(); 
  }
  

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
    final palette = settings.current;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: palette.primary,
        scaffoldBackgroundColor: palette.background,
        cardColor: palette.surface,
        // Force the ColorScheme to use your specific palette colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: palette.primary, 
          brightness: Brightness.light,
        ).copyWith(
          primary: palette.primary,
          surface: palette.surface,
          background: palette.background,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: palette.primary,
        scaffoldBackgroundColor: palette.background,
        cardColor: palette.surface,
        // Force the ColorScheme to use your specific palette colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: palette.primary, 
          brightness: Brightness.dark,
        ).copyWith(
          primary: palette.primary,
          surface: palette.surface,
          background: palette.background,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (!authSnapshot.hasData || authSnapshot.data == null) {
            return const LoginPage();
          }
          return FutureBuilder<bool>(
            future: AppState.isFirstRun(),
            builder: (context, firstRunSnapshot) {
              if (firstRunSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (firstRunSnapshot.data == true) {
                return const AcknowledgementPage();
              }
              AnalyticsService().initializeUser();
              return const MainScreen();
            },
          );
        },
      ),
    );
  }
}