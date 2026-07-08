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
    _initPath();
  }

  void _initPath() async {
    final path = await FolderService.getPastPapersPath();
    setState(() {
      folderPath = path;
      papers = FileScanner.scan(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjects = FilterLogic.getSubjects(papers);
    bool isSelectionComplete = (subject != null && series != null && year != null && type != null) && (type == "gt" || paper != null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Library"), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 10, runSpacing: 10,
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
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: _openInReader,
                  child: const Text("Open in App Reader", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openInReader() {
    final match = papers.firstWhere((p) => p.subject == subject && p.series == series && p.year == year && p.type == type && (type == "gt" || p.paper == paper));
    
    // Send to Reader
    Provider.of<ReaderController>(context, listen: false).openFile(
      match.path.split(Platform.pathSeparator).last, 
      match.path
    );
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opened in Reader Tab")));
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String) onCh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
      child: DropdownButton<String>(
        value: value, hint: Text(label), underline: const SizedBox(),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onCh(v!),
      ),
    );
  }
}