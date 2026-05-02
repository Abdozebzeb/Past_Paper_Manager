import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../logic/file_scanner.dart';
import '../../logic/filter_logic.dart';
import '../../logic/paper_model.dart';
import '../../services/file_open_service.dart';
import '../../services/folder_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

class ViewPapersPage extends StatefulWidget {
  const ViewPapersPage({Key? key}) : super(key: key);
  @override
  _ViewPapersPageState createState() => _ViewPapersPageState();
}

class _ViewPapersPageState extends State<ViewPapersPage> {
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

  void _openInternalFolder() async {
    final String path = FolderService.getPastPapersPath();
    final Uri uri = Uri.directory(path);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar("Could not open folder: $path");
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar("Could not open link");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF252D3D),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: const Text("Past Papers Library", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 40), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  
                  Column(
                    children: [
                      _sectionCard(
                        title: "Filter Papers",
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 12,
                              alignment: WrapAlignment.start,
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
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: isSelectionComplete ? openFile : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  disabledBackgroundColor: Colors.white10,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text("Open Paper", 
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionCard(
                        title: "Library Info",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statItem("Total Files", papers.length.toString()),
                            const VerticalDivider(color: Colors.white10),
                            
                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end, 
                              children: [
                                const Text("Storage", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 5),
                                InkWell(
                                  onTap: _openInternalFolder,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withAlpha(25), 
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blueAccent.withAlpha(60)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.folder_open_rounded, size: 14, color: Colors.blueAccent),
                                        const SizedBox(width: 6),
                                        Text(
                                          folderPath.split(Platform.pathSeparator).last,
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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

                  
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 10),
                    child: Column(
                      children: [
                        Text(
                          "Created with ❤️ for Students, By Abdullah Zeb",
                          style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.github, size: 18),
                              color: Colors.white.withOpacity(0.5),
                              onPressed: () => _launchURL("https://github.com/Abdozebzeb"),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.instagram, size: 18),
                              color: Colors.white.withOpacity(0.5),
                              onPressed: () => _launchURL("https://www.instagram.com/abdullahhzeb/"),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
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
        },
      ),
    );
  }

  
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF161D2D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, {bool isPath = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(
          value, 
          style: TextStyle(
            color: isPath ? Colors.blueAccent : Colors.white, 
            fontSize: 14, 
            fontWeight: FontWeight.bold,
            decoration: isPath ? TextDecoration.underline : TextDecoration.none, 
          )
        ),
      ],
    );
  }

  Widget _buildPillDropdown({
    required String label,
    required String? selectedValue,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2335),
        borderRadius: BorderRadius.circular(30), 
        border: Border.all(color: Colors.blueAccent.withAlpha(40)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          dropdownColor: const Color(0xFF1A2335),
          icon: const Icon(Icons.expand_more, color: Colors.blueAccent, size: 20),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ),
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
      _showSnackBar("No file found. Check your selections.");
      return;
    }
    FileOpenService.openFile(matches.first.path);
  }
}