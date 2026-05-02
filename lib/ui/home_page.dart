import 'package:flutter/material.dart';

import '../logic/file_scanner.dart';
import '../logic/filter_logic.dart';
import '../logic/paper_model.dart';
import '../services/file_open_service.dart';
import '../services/folder_service.dart';
import 'debug.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


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

  
  void _launchURL(String url) async {
  final uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Could not open link")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final subjects = FilterLogic.getSubjects(papers);

    bool isSelectionComplete = false;
    if (subject != null && series != null && year != null && type != null) {
      if (type == "gt") {
        isSelectionComplete = true;
      } else if (paper != null) {
        isSelectionComplete = true;
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
            Wrap(
              spacing: 10,
              runSpacing: 12,
              alignment: WrapAlignment.center, 
              crossAxisAlignment: WrapCrossAlignment.center,
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
                  ),
                  child: Text("Open Paper", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],

            SizedBox(height: 40),
            
            DebugPanel(
              onRefresh: refreshFiles,
              folderPath: folderPath,
            ),
          ],
        ),
      ),

      
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Created with ❤️ for Students By Abdullah Zeb",
              style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.github,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                  onPressed: () => _launchURL("https://github.com/yourusername"),
                  tooltip: "GitHub",
                ),

                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                  onPressed: () => _launchURL("https://instagram.com/yourusername"),
                  tooltip: "Instagram",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
        color: Color(0xFF161D2D),
        borderRadius: BorderRadius.circular(30),
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