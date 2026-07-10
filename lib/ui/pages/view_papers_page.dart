import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../logic/file_scanner.dart';
import '../../logic/filter_logic.dart';
import '../../logic/paper_model.dart';
import '../../logic/reader_controller.dart';
import '../../logic/library_provider.dart';
import '../../services/folder_service.dart';
import '../../services/analytics_service.dart';

class ViewPapersPage extends StatefulWidget {
  const ViewPapersPage({super.key});
  @override
  State<ViewPapersPage> createState() => _ViewPapersPageState();
}

class _ViewPapersPageState extends State<ViewPapersPage> {
  @override
  void initState() {
    super.initState();
    // Refresh list on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LibraryProvider>(context, listen: false).refreshFiles();
    });
  }

  Future<void> _openPaperLogic(LibraryProvider lib, String? p) async {
    try {
      final match = lib.papers.firstWhere((item) =>
          item.subject == lib.subject &&
          item.series == lib.series &&
          item.year == lib.year &&
          item.type == lib.type &&
          (lib.type == "gt" || item.paper == p));
      
      final fileName = match.path.split(Platform.pathSeparator).last;
      
      // Open file and switch to Reader screen
      final reader = Provider.of<ReaderController>(context, listen: false);
      reader.openFile(fileName, match.path);
      reader.setMenuIndex(2); 
      
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
    final lib = Provider.of<LibraryProvider>(context);
    final subjects = FilterLogic.getSubjects(lib.papers);
    
    bool isComplete = (lib.subject != null && lib.series != null && lib.year != null && lib.type != null) &&
        (lib.type == "gt" || lib.paper != null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Past Papers Library", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
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
                        child: SizedBox(
                          height: 55, 
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Theme.of(context).disabledColor.withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), 
                              elevation: 0,
                            ),
                            onPressed: isComplete ? () => _openPaperLogic(lib, lib.paper) : null,
                            child: const Text("Open Paper", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                      if (isComplete) ...[
                        const SizedBox(width: 12),
                        _moreOptionsButton(lib),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem("Total Files", lib.papers.length.toString()),
                  InkWell(
                    onTap: () => FolderService.openFolder(lib.folderPath),
                    borderRadius: BorderRadius.circular(10),
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
            ),
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
        onSelected: (val) => _openPaperLogic(lib, val == "gt" ? null : lib.paper),
        itemBuilder: (context) => [
          if (lib.type != "qp") const PopupMenuItem(value: "qp", child: Text("Open Question Paper")),
          if (lib.type != "ms") const PopupMenuItem(value: "ms", child: Text("Open Marking Scheme")),
          if (lib.type != "gt") const PopupMenuItem(value: "gt", child: Text("Open Grade Threshold")),
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
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _pill(String label, String? val, List<String> items, Function(String) onCh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          dropdownColor: Theme.of(context).cardColor,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => onCh(val!),
        ),
      ),
    );
  }
}