import 'package:flutter/material.dart';
import '../logic/file_scanner.dart';
import '../logic/filter_logic.dart';
import '../logic/paper_model.dart';
import '../services/file_open_service.dart';
import '../services/folder_service.dart';
import 'debug.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/analytics_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Paper> papers = [];
  String folderPath = "";

  String? subject, series, year, type, paper;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final path = await FolderService.getPastPapersPath();
    if (!mounted) return;
    setState(() {
      folderPath = path;
      papers = FileScanner.scan(path);
    });
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open link")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = FilterLogic.getSubjects(papers);
    bool isSelectionComplete = (subject != null && series != null && year != null && type != null) && (type == "gt" || paper != null);

    return Scaffold(
      backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Past Papers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Wrap(
              spacing: 10, runSpacing: 12,
              children: [
                _buildDropdown("Subject", subject, subjects, (v) => setState(() { subject = v; series = year = type = paper = null; })),
                if (subject != null) _buildDropdown("Series", series, FilterLogic.getSeries(papers, subject!), (v) => setState(() { series = v; year = type = paper = null; })),
                if (series != null) _buildDropdown("Year", year, FilterLogic.getYears(papers, subject!, series!), (v) => setState(() { year = v; type = paper = null; })),
                if (year != null) _buildDropdown("Type", type, FilterLogic.getTypes(papers, subject!, series!, year!), (v) => setState(() { type = v; paper = null; })),
                if (type != null && type != "gt") _buildDropdown("Paper", paper, FilterLogic.getPapers(papers, subject!, series!, year!, type!), (v) => setState(() => paper = v)),
              ],
            ),
            const SizedBox(height: 30),
            if (isSelectionComplete)
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    final match = papers.firstWhere((p) => p.subject == subject && p.series == series && p.year == year && p.type == type && (type == "gt" || p.paper == paper));
                    FileOpenService.openFile(match.path);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                  child: const Text("Open Paper", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 40),
            DebugPanel(onRefresh: _refresh, folderPath: folderPath),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String) onCh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color:  Theme.of(context).cardColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: Theme.of(context).primaryColor.withAlpha(100))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, hint: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          dropdownColor: const Color(0xFF1A2335), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => onCh(val!),
        ),
      ),
    );
  }
}

// extension on Theme {
//   Color? get cardColor => null;
  
//   Color? get scaffoldBackgroundColor => null;
// }