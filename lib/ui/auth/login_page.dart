import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../logic/app_state.dart';
import 'acknowledgement_page.dart';
import '../main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              const Text("CIE Manager", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text("Sign in to manage your past papers", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    final user = await AuthService().signInWithGoogle();
                    
                    if (user != null) {
                      await AnalyticsService().initializeUser();
                      
                      if (mounted) {
                        final isFirst = await AppState.isFirstRun();
                        if (mounted) {
                          if (isFirst) {
                            
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (_) => const AcknowledgementPage())
                            );
                          } else {
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (_) => const MainScreen())
                            );
                          }
                        }
                      }
                    }
                    if (mounted) setState(() => _isLoading = false);
                  },
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.google, size: 18),
                            SizedBox(width: 12),
                            Text("Sign in with Google", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// extension on Theme {
//   Color? get scaffoldBackgroundColor => null;
// }