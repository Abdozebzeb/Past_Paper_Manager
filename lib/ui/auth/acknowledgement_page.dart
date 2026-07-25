import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../logic/app_state.dart';
import '../main_screen.dart';
import '../../app_config.dart';

class AcknowledgementPage extends StatelessWidget {
  const AcknowledgementPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:  Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1))
                ),
                child: Markdown(
                  data: AppConfig.acknowledgementContent, 
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.white70, fontSize: 14),
                    h1: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  )
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, 
              height: 55, 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await AppState.setNotFirstRun();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (_) => const MainScreen())
                    );
                  }
                },
                child: const Text("I Agree & Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// extension on Theme {
//   Color? get scaffoldBackgroundColor => null;
  
//   Color? get cardColor => null;
// }