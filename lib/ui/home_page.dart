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

    // --- LOGIC: Show button only when selection is complete ---
    bool isSelectionComplete = false;
    if (subject != null && series != null && year != null && type != null) {
      if (type == "gt") {
        isSelectionComplete = true; // Grade Threshold doesn't need a paper number
      } else if (paper != null) {
        isSelectionComplete = true; // Other types (qp, ms, etc.) need a paper number
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF0A0F1C),
      appBar: AppBar(
        title: Text("Past Papers", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- MODERN PILL DROPDOWNS ---
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                _buildPillDropdown(
                  label: "Subject",
                  selectedValue: subject,
                  items: subjects,
                  onChanged: (val) => setState(() {
                    subject = val;
                    series = year = type = paper = null;
                  }),
                ),
                if (subject != null)
                  _buildPillDropdown(
                    label: "Series",
                    selectedValue: series,
                    items: FilterLogic.getSeries(papers, subject!),
                    onChanged: (val) => setState(() {
                      series = val;
                      year = type = paper = null;
                    }),
                  ),
                if (series != null)
                  _buildPillDropdown(
                    label: "Year",
                    selectedValue: year,
                    items: FilterLogic.getYears(papers, subject!, series!),
                    onChanged: (val) => setState(() {
                      year = val;
                      type = paper = null;
                    }),
                  ),
                if (year != null)
                  _buildPillDropdown(
                    label: "Type",
                    selectedValue: type,
                    items: FilterLogic.getTypes(papers, subject!, series!, year!),
                    onChanged: (val) => setState(() {
                      type = val;
                      paper = null;
                    }),
                  ),
                if (type != null && type != "gt")
                  _buildPillDropdown(
                    label: "Paper",
                    selectedValue: paper,
                    items: FilterLogic.getPapers(papers, subject!, series!, year!, type!),
                    onChanged: (val) => setState(() {
                      paper = val;
                    }),
                  ),
              ],
            ),

            // --- CONDITIONAL OPEN BUTTON ---
            if (isSelectionComplete) ...[
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: openFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 8,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text("Open Paper", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],

            SizedBox(height: 40),
            
            // --- DEBUG SECTION ---
            DebugPanel(
              onRefresh: refreshFiles,
              folderPath: folderPath,
            ),
          ],
        ),
      ),
    );
  }

  // REBUILT: Slim, Pill-shaped Dropdown
  Widget _buildPillDropdown({
    required String label,
    required String? selectedValue,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      constraints: BoxConstraints(minWidth: 100, maxWidth: 160),
      padding: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Color(0xFF161D2D), // Subtle contrast from background
        borderRadius: BorderRadius.circular(30), // Rounded pill shape
        border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(label, style: TextStyle(color: Colors.grey, fontSize: 13)),
          dropdownColor: Color(0xFF1A2335),
          isExpanded: true,
          icon: Icon(Icons.expand_more, color: Colors.blueAccent, size: 20),
          style: TextStyle(color: Colors.white, fontSize: 13),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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