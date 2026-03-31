import 'package:flutter/material.dart';
import 'ui/home_page.dart';
import 'logic/app_state.dart';
import 'services/folder_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String folderPath = "assets/PastPapers";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0A0F1C),
        primaryColor: Colors.blueAccent,
      ),
      home: FutureBuilder(
        future: AppState.isFirstRun(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();

          if (snapshot.data == true) {
            return FirstRunScreen(folderPath);
          }

          return HomePage();
        },
      ),
    );
  }
}

class FirstRunScreen extends StatelessWidget {
  final String folderPath;

  FirstRunScreen(this.folderPath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AlertDialog(
          title: Text("Setup Required"),
          content: Text("Place the Past Papers in:\n$folderPath"),
          actions: [
            TextButton(
              onPressed: () {
                FolderService.openFolder(folderPath);
              },
              child: Text("Open Folder"),
            ),
            TextButton(
              onPressed: () async {
                await AppState.setNotFirstRun();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()));
              },
              child: Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}