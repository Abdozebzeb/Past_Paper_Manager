import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../logic/file_scanner.dart';
import '../../logic/filter_logic.dart';
import '../../logic/paper_model.dart';
import '../../logic/reader_controller.dart';
import '../../services/folder_service.dart';
import '../../services/analytics_service.dart';

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

  Future<void> _openPaperLogic(String sub, String ser, String yr, String ty, String? p) async {
    try {
      final match = papers.firstWhere((item) =>
          item.subject == sub &&
          item.series == ser &&
          item.year == yr &&
          item.type == ty &&
          (ty == "gt" || item.paper == p));
      
      final fileName = match.path.split(Platform.pathSeparator).last;
      
      // 1. Open in Reader
      Provider.of<ReaderController>(context, listen: false).openFile(fileName, match.path);
      
      // 2. Log to Firebase
      final analytics = AnalyticsService();
      String? uid = await analytics.getStoredUserId();
      if (uid != null) {
        await analytics.logPaperOpen(uid, fileName);
        await analytics.logButtonClick("open_paper_ui", uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File not found locally.")));
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
        title: const Text("Past Papers Library", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh, color: Colors.blueAccent)),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // --- FILTER CARD ---
            _sectionCard(
              title: "Filter Papers",
              child: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 15,
                    children: [
                      _pill("Subject", subject, subjects, (v) => setState(() {
                        subject = v; series = year = type = paper = null;
                      })),
                      if (subject != null)
                        _pill("Series", series, FilterLogic.getSeries(papers, subject!), (v) => setState(() {
                          series = v; year = type = paper = null;
                        })),
                      if (series != null)
                        _pill("Year", year, FilterLogic.getYears(papers, subject!, series!), (v) => setState(() {
                          year = v; type = paper = null;
                        })),
                      if (year != null)
                        _pill("Type", type, FilterLogic.getTypes(papers, subject!, series!, year!), (v) => setState(() {
                          type = v; paper = null;
                        })),
                      if (type != null && type != "gt")
                        _pill("Paper", paper, FilterLogic.getPapers(papers, subject!, series!, year!, type!), (v) => setState(() => paper = v)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  if (isComplete)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              onPressed: () => _openPaperLogic(subject!, series!, year!, type!, paper),
                              child: const Text("Open Paper", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _moreOptionsButton(),
                      ],
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),

            // --- LIBRARY INFO CARD ---
            _sectionCard(
              title: "Library Info",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem("Total Files", papers.length.toString()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Storage", style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => FolderService.openFolder(folderPath),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.folder_open, size: 16, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text("Past Papers", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreOptionsButton() {
    return Container(
      height: 55, width: 55,
      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(14)),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
        onSelected: (val) => _openPaperLogic(subject!, series!, year!, val, paper),
        itemBuilder: (context) => [
          if (type != "qp") const PopupMenuItem(value: "qp", child: Text("Open Question Paper")),
          if (type != "ms") const PopupMenuItem(value: "ms", child: Text("Open Marking Scheme")),
          if (type != "gt") const PopupMenuItem(value: "gt", child: Text("Open Grade Threshold")),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161D2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _pill(String label, String? val, List<String> items, Function(String) onCh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2335),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          dropdownColor: const Color(0xFF1A2335),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => onCh(val!),
        ),
      ),
    );
  }
}