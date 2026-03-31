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
        title: Text("Past Papers", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView( // Added to prevent overflow on small screens
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HORIZONTAL FLOW SECTION ---
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                dropdown(
                  label: "Subject",
                  selectedValue: subject,
                  items: subjects,
                  onChanged: (val) {
                    setState(() {
                      subject = val;
                      series = year = type = paper = null;
                    });
                  },
                ),

                if (subject != null)
                  dropdown(
                    label: "Series",
                    selectedValue: series,
                    items: FilterLogic.getSeries(papers, subject!),
                    onChanged: (val) {
                      setState(() {
                        series = val;
                        year = type = paper = null;
                      });
                    },
                  ),

                if (series != null)
                  dropdown(
                    label: "Year",
                    selectedValue: year,
                    items: FilterLogic.getYears(papers, subject!, series!),
                    onChanged: (val) {
                      setState(() {
                        year = val;
                        type = paper = null;
                      });
                    },
                  ),

                if (year != null)
                  dropdown(
                    label: "Type",
                    selectedValue: type,
                    items: FilterLogic.getTypes(papers, subject!, series!, year!),
                    onChanged: (val) {
                      setState(() {
                        type = val;
                        paper = null;
                      });
                    },
                  ),

                if (type != null && type != "gt")
                  dropdown(
                    label: "Paper",
                    selectedValue: paper,
                    items: FilterLogic.getPapers(papers, subject!, series!, year!, type!),
                    onChanged: (val) {
                      setState(() {
                        paper = val;
                      });
                    },
                  ),
              ],
            ),

            SizedBox(height: 30),

            // --- ACTION BUTTON ---
            ElevatedButton(
              onPressed: openFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Open Paper", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),

            SizedBox(height: 20),

            // --- DEBUG PANEL ---
            DebugPanel(
              onRefresh: refreshFiles,
              folderPath: folderPath,
            ),
          ],
        ),
      ),
    );
  }

  // REBUILT DROPDOWN: Now with selection logic and modern styling
  Widget dropdown({
    required String label,
    required String? selectedValue,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    // Constraints are needed inside a Wrap to give the dropdown a base width
    return Container(
      constraints: BoxConstraints(minWidth: 150, maxWidth: 200),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFF121A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
          dropdownColor: Color(0xFF1A2335),
          isExpanded: true,
          iconEnabledColor: Colors.blueAccent,
          style: TextStyle(color: Colors.white, fontSize: 14),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ),
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
        (type == "gt" || p.paper == paper)).toList();

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No file found. Check your selections.")),
      );
      return;
    }

    FileOpenService.openFile(matches.first.path);
  }
}