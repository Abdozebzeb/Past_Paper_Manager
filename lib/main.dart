import 'package:flutter/material.dart';
import 'ui/home_page.dart';
import 'logic/app_state.dart';
import 'services/folder_service.dart';
import 'ui/main_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'services/analytics_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  
  await AnalyticsService().initializeUser();
  
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0F1C),
        primaryColor: Colors.blueAccent,
      ),
      home: FutureBuilder(
        future: AppState.isFirstRun(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          
          if (snapshot.data == true) {
            return FirstRunScreen(FolderService.getPastPapersPath());
          }

          
          return const MainScreen();
          
        },
      ),
    );
  }
}

class FirstRunScreen extends StatelessWidget {
  final String folderPath;

  const FirstRunScreen(this.folderPath, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C), 
      body: Center(
        child: Container(
          width: 440, 
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: const Color(0xFF161D2D), 
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.blueAccent, size: 32),
              ),
              const SizedBox(height: 24),

              
              const Text(
                "Welcome to Past Paper Manager", 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 16),

              
              Text(
                "Your all-in-one hub for past papers. We've organized everything so you can focus on acing your exams.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 35),

              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await AppState.setNotFirstRun();
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        "Lets Go!", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "Press to continue to your dashboard",
                style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.5)),
              ),
              const SizedBox(height: 15),
              Text(
                "Abdullah Zeb - 2026",
                style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}