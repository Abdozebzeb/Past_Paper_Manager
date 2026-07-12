import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../logic/app_state.dart';
import '../main_screen.dart';

class AcknowledgementPage extends StatelessWidget {
  const AcknowledgementPage({super.key});

  final String content = """
# Terms & Privacy
Welcome to the **CIE Past Paper Manager**.

* This app helps you download and view past papers.
* We use Google Sign-in to keep your preferences safe.
* We do not sell your data.
* **Disclaimer:** This is a student project and not affiliated with Cambridge.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2D), 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.1))
                ),
                child: Markdown(
                  data: content, 
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.white70, fontSize: 14),
                    h1: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
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
                  backgroundColor: Colors.blueAccent,
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