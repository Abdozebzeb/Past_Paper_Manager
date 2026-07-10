import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../logic/file_scanner.dart';
import '../../logic/filter_logic.dart';
import '../../logic/paper_model.dart';
import '../../logic/reader_controller.dart';
import '../../logic/library_provider.dart';
import '../../services/folder_service.dart';

class ViewPapersPage extends StatefulWidget {
  const ViewPapersPage({super.key});
  @override
  State<ViewPapersPage> createState() => _ViewPapersPageState();
}

class _ViewPapersPageState extends State<ViewPapersPage> {
  // Mapping internal codes to user-friendly names
  final Map<String, String> _displayNames = {
    's': 'Summer', 
    'w': 'Winter', 
    'm': 'March',
    'qp': 'Question Paper', 
    'ms': 'Marking Scheme', 
    'gt': 'Grading Threshold'
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LibraryProvider>(context, listen: false).refreshFiles();
    });
  }

  Future<void> _openPaperLogic(LibraryProvider lib, {String? overrideType}) async {
    try {
      final targetType = overrideType ?? lib.type;
      // If we are opening a Grading Threshold, we don't look for a specific paper number (e.g. _22)
      final targetPaper = (targetType == "gt") ? null : lib.paper;

      final match = lib.papers.firstWhere((item) =>
          item.subject == lib.subject &&
          item.series == lib.series &&
          item.year == lib.year &&
          item.type == targetType &&
          (targetType == "gt" || item.paper == targetPaper));
      
      final fileName = match.path.split(Platform.pathSeparator).last;
      Provider.of<ReaderController>(context, listen: false).openFile(fileName, match.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File not found: ${_displayNames[overrideType] ?? 'Paper'}"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lib = Provider.of<LibraryProvider>(context);
    final subjects = FilterLogic.getSubjects(lib.papers);
    
    bool isComplete = (lib.subject != null && lib.series != null && lib.year != null && lib.type != null) && 
                      (lib.type == "gt" || lib.paper != null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Past Papers Library", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.transparent, 
        elevation: 0
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // --- FILTER CARD ---
            Container(
              width: double.infinity, padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, 
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(color: Colors.blueAccent.withOpacity(0.1))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter Papers", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 25),
                  Center(
                    child: Wrap(
                      spacing: 12, runSpacing: 15, alignment: WrapAlignment.center, 
                      children: [
                        _pill("Subject", lib.subject, subjects, (v) => lib.setSelection(sub: v)),
                        if (lib.subject != null) _pill("Series", lib.series, FilterLogic.getSeries(lib.papers, lib.subject!), (v) => lib.setSelection(ser: v)),
                        if (lib.series != null) _pill("Year", lib.year, FilterLogic.getYears(lib.papers, lib.subject!, lib.series!), (v) => lib.setSelection(yr: v)),
                        if (lib.year != null) _pill("Type", lib.type, FilterLogic.getTypes(lib.papers, lib.subject!, lib.series!, lib.year!), (v) => lib.setSelection(ty: v)),
                        if (lib.type != null && lib.type != "gt") _pill("Paper", lib.paper, FilterLogic.getPapers(lib.papers, lib.subject!, lib.series!, lib.year!, lib.type!), (v) => lib.setSelection(p: v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), 
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(height: 55, 
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent, 
                              foregroundColor: Colors.white, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), 
                              elevation: 0
                            ),
                            onPressed: isComplete ? () => _openPaperLogic(lib) : null,
                            child: const Text("Open Paper", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                      if (isComplete) ...[
                        const SizedBox(width: 12), 
                        _moreOptionsButton(lib)
                      ]
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _infoCard(lib),
          ],
        ),
      ),
    );
  }

  Widget _moreOptionsButton(LibraryProvider lib) {
    return Container(
      height: 55, width: 55,
      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(14)),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
        onSelected: (val) => _openPaperLogic(lib, overrideType: val),
        itemBuilder: (context) => [
          // Logic: Only show the option if it is NOT the currently selected type in the dropdown
          if (lib.type != "qp") 
            const PopupMenuItem(value: "qp", child: Text("Open Question Paper")),
          if (lib.type != "ms") 
            const PopupMenuItem(value: "ms", child: Text("Open Marking Scheme")),
          if (lib.type != "gt") 
            const PopupMenuItem(value: "gt", child: Text("Open Grade Threshold")),
        ],
      ),
    );
  }

  Widget _pill(String label, String? val, List<String> items, Function(String) onCh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(30), 
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2))
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val, 
          hint: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          dropdownColor: Theme.of(context).cardColor,
          items: items.map((e) => DropdownMenuItem(
            value: e, 
            child: Text(_displayNames[e] ?? e)
          )).toList(),
          onChanged: (val) => onCh(val!),
        ),
      ),
    );
  }

  Widget _infoCard(LibraryProvider lib) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              const Text("Total Files", style: TextStyle(color: Colors.grey, fontSize: 11)), 
              const SizedBox(height: 4), 
              Text(lib.papers.length.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
            ]
          ),
          InkWell(
            onTap: () => FolderService.openFolder(lib.folderPath),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.folder_open, size: 16, color: Colors.blueAccent), 
                  SizedBox(width: 8), 
                  Text("Past Papers", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12))
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}