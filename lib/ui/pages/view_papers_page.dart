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
    _refresh();
  }

  void _refresh() async {
    final path = await FolderService.getPastPapersPath();
    if (mounted) {
      setState(() {
        folderPath = path;
        papers = FileScanner.scan(path);
      });
    }
  }

  
  void _openPaperPath(String sub, String ser, String yr, String ty, String? p) {
    try {
      final match = papers.firstWhere((item) =>
          item.subject == sub &&
          item.series == ser &&
          item.year == yr &&
          item.type == ty &&
          (ty == "gt" || item.paper == p));
      
      Provider.of<ReaderController>(context, listen: false)
          .openFile(match.path.split(Platform.pathSeparator).last, match.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File not found in local library.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = FilterLogic.getSubjects(papers);
    bool isComplete = (subject != null && series != null && year != null && type != null) &&
        (type == "gt" || paper != null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Past Papers Library", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            
            Wrap(
              spacing: 12,
              runSpacing: 15,
              children: [
                _pill("Subject", subject, subjects, (v) => setState(() {
                  subject = v;
                  series = year = type = paper = null;
                })),
                if (subject != null)
                  _pill("Series", series, FilterLogic.getSeries(papers, subject!), (v) => setState(() {
                    series = v;
                    year = type = paper = null;
                  })),
                if (series != null)
                  _pill("Year", year, FilterLogic.getYears(papers, subject!, series!), (v) => setState(() {
                    year = v;
                    type = paper = null;
                  })),
                if (year != null)
                  _pill("Type", type, FilterLogic.getTypes(papers, subject!, series!, year!), (v) => setState(() {
                    type = v;
                    paper = null;
                  })),
                if (type != null && type != "gt")
                  _pill("Paper", paper, FilterLogic.getPapers(papers, subject!, series!, year!, type!), (v) => setState(() => paper = v)),
              ],
            ),
            
            const SizedBox(height: 40),

            
            if (isComplete)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                        ),
                        onPressed: () => _openPaperPath(subject!, series!, year!, type!, paper),
                        child: const Text("Open Paper", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (val) => _openPaperPath(subject!, series!, year!, val, paper),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "qp", child: Text("Open Question Paper")),
                        const PopupMenuItem(value: "ms", child: Text("Open Marking Scheme")),
                        const PopupMenuItem(value: "gt", child: Text("Open Grade Threshold")),
                      ],
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 50),
            _infoCard(),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, String? val, List<String> items, Function(String) onCh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.blueAccent.withAlpha(80)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          dropdownColor: Theme.of(context).cardColor,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => onCh(val!),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Library Path: ${folderPath.split(Platform.pathSeparator).last}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}