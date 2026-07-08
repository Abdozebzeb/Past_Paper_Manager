import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../logic/file_scanner.dart';
import '../../logic/filter_logic.dart';
import '../../logic/paper_model.dart';
import '../../logic/reader_controller.dart';
import '../../services/folder_service.dart';

class ViewPapersPage extends StatefulWidget {
  const ViewPapersPage({super.key});
  @override
  State<ViewPapersPage> createState() => _ViewPapersPageState();
}

class _ViewPapersPageState extends State<ViewPapersPage> {
  List<Paper> papers = [];
  String folderPath = "";
  String? subject, series, year, type, paper;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final path = await FolderService.getPastPapersPath();
    if (mounted) setState(() { folderPath = path; papers = FileScanner.scan(path); });
  }

  @override
  Widget build(BuildContext context) {
    final subjects = FilterLogic.getSubjects(papers);
    bool isComplete = (subject != null && series != null && year != null && type != null) && (type == "gt" || paper != null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Past Papers Library", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Wrap(
              spacing: 12, runSpacing: 15,
              children: [
                _pillDropdown("Subject", subject, subjects, (v) => setState(() { subject = v; series = year = type = paper = null; })),
                if (subject != null) _pillDropdown("Series", series, FilterLogic.getSeries(papers, subject!), (v) => setState(() { series = v; year = type = paper = null; })),
                if (series != null) _pillDropdown("Year", year, FilterLogic.getYears(papers, subject!, series!), (v) => setState(() { year = v; type = paper = null; })),
                if (year != null) _pillDropdown("Type", type, FilterLogic.getTypes(papers, subject!, series!, year!), (v) => setState(() { type = v; paper = null; })),
                if (type != null && type != "gt") _pillDropdown("Paper", paper, FilterLogic.getPapers(papers, subject!, series!, year!, type!), (v) => setState(() => paper = v)),
              ],
            ),
            const SizedBox(height: 40),
            if (isComplete)
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 10),
                  onPressed: () {
                    final match = papers.firstWhere((p) => p.subject == subject && p.series == series && p.year == year && p.type == type && (type == "gt" || p.paper == paper));
                    Provider.of<ReaderController>(context, listen: false).openFile(match.path.split(Platform.pathSeparator).last, match.path);
                  },
                  child: const Text("Open Paper", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 50),
            _infoCard(),
          ],
        ),
      ),
    );
  }

  Widget _pillDropdown(String label, String? val, List<String> items, Function(String) onCh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: const Color(0xFF161D2D), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blueAccent.withAlpha(80))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val, hint: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          dropdownColor: const Color(0xFF1A2335), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onCh(v!),
        ),
      ),
    );
  }

  Widget _infoCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.blueAccent.withAlpha(20), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withAlpha(40))),
    child: Row(children: [const Icon(Icons.folder, color: Colors.blueAccent), const SizedBox(width: 15), Text("Library Path: ${folderPath.split(Platform.pathSeparator).last}", style: const TextStyle(color: Colors.grey, fontSize: 12))]),
  );
}