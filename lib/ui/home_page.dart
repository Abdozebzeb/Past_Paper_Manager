import 'package:flutter/material.dart';
import '../logic/file_scanner.dart';
import '../logic/filter_logic.dart';
import '../logic/paper_model.dart';
import '../services/file_open_service.dart';
import '../services/folder_service.dart';
import 'debug.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Paper> papers = [];
  late String folderPath;

  String? subject;
  String? series;
  String? year;
  String? type;
  String? paper;

  @override
  void initState() {
    super.initState();
    folderPath = FolderService.getPastPapersPath();
    papers = FileScanner.scan(folderPath);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = FilterLogic.getSubjects(papers);

    return Scaffold(
      backgroundColor: Color(0xFF0A0F1C),
      appBar: AppBar(
        title: Text("Past Papers"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            dropdown("Subject", subjects, (val) {
              setState(() {
                subject = val;
                series = year = type = paper = null;
              });
            }),

            if (subject != null)
              dropdown("Series",
                  FilterLogic.getSeries(papers, subject!), (val) {
                setState(() {
                  series = val;
                  year = type = paper = null;
                });
              }),

            if (series != null)
              dropdown("Year",
                  FilterLogic.getYears(papers, subject!, series!), (val) {
                setState(() {
                  year = val;
                  type = paper = null;
                });
              }),

            if (year != null)
              dropdown("Type",
                  FilterLogic.getTypes(papers, subject!, series!, year!),
                  (val) {
                setState(() {
                  type = val;
                  paper = null;
                });
              }),

            if (type != null && type != "gt")
              dropdown(
                  "Paper",
                  FilterLogic.getPapers(
                      papers, subject!, series!, year!, type!), (val) {
                setState(() {
                  paper = val;
                });
              }),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: openFile,
              child: Text("Open"),
              
            ),

            DebugPanel(
              onRefresh: refreshFiles,
              folderPath: folderPath,
            ),
            
          ],
        ),
      ),
    );
  }

  Widget dropdown(String label, List<String> items, Function(String) onChanged) {
    return DropdownButton<String>(
      hint: Text(label),
      value: null,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) => onChanged(val!),
    );
  }

  void refreshFiles() {
    setState(() {
      papers = FileScanner.scan(folderPath);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Files refreshed")),
    );
  }

    void openFile() {
      final matches = papers.where((p) =>
          p.subject == subject &&
          p.series == series &&
          p.year == year &&
          p.type == type &&
          (type == "gt" || p.paper == paper)
      ).toList();

      if (matches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No file found. Check your selections.")),
        );
        return;
      }

      FileOpenService.openFile(matches.first.path);
    }
}