import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../logic/reader_controller.dart';
import '../../logic/library_provider.dart';
import 'reader_side_panel.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});
  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  void _handleScrollZoom(PointerSignalEvent event, ReaderController reader) {
    if (event is PointerScrollEvent && HardwareKeyboard.instance.isControlPressed) {
      double delta = event.scrollDelta.dy < 0 ? 0.1 : -0.1;
      reader.updateZoom(reader.currentTabIndex, reader.openFiles[reader.currentTabIndex].zoom + delta);
    }
  }

  void _showTabContextMenu(BuildContext context, int index, ReaderController reader, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(onTap: () => reader.closeTab(index), child: const Text("Close Tab")),
        PopupMenuItem(onTap: () => reader.closeOthers(index), child: const Text("Close Other Tabs")),
        PopupMenuItem(onTap: () => reader.closeToRight(index), child: const Text("Close Tabs to Right")),
        PopupMenuItem(onTap: () => reader.closeAllTabs(), child: const Text("Close All Tabs")),
      ],
    );
  }

  // Logic to open related files (MS/GT/QP) from a tab
  void _openRelated(String type, OpenedFile currentFile) {
    final lib = Provider.of<LibraryProvider>(context, listen: false);
    final reader = Provider.of<ReaderController>(context, listen: false);
    
    try {
      final parts = currentFile.name.replaceAll('.pdf', '').split('_');
      final subject = parts[0];
      final series = parts[1][0];
      final year = parts[1].substring(1);
      final paperNum = parts.length > 3 ? parts[3] : null;

      final match = lib.papers.firstWhere((p) => 
        p.subject == subject && p.series == series && p.year == year && p.type == type && (type == 'gt' || p.paper == paperNum)
      );
      reader.openFile(match.path.split(Platform.pathSeparator).last, match.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Related file not found in library.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final reader = Provider.of<ReaderController>(context);
    if (reader.openFiles.isEmpty) return const Center(child: Text("No papers are currently open."));

    final currentFile = reader.openFiles[reader.currentTabIndex];

    return Column(
      children: [
        Container(
          height: 50,
          color: Theme.of(context).cardColor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reader.openFiles.length,
            itemBuilder: (context, index) {
              final isSelected = reader.currentTabIndex == index;
              final file = reader.openFiles[index];
              
              return GestureDetector(
                onTap: () => reader.setTab(index),
                onSecondaryTapDown: (details) => _showTabContextMenu(context, index, reader, details.globalPosition),
                child: Container(
                  margin: const EdgeInsets.only(left: 8, top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Colors.black12,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    border: isSelected ? Border(top: BorderSide(color: Theme.of(context).primaryColor, width: 2)) : null,
                  ),
                  child: Row(
                    children: [
                      // QUICK ACTION DROPDOWN
                      PopupMenuButton<String>(
                        tooltip: "Quick Actions",
                        icon: Icon(Icons.arrow_drop_down, size: 18, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
                        onSelected: (val) => _openRelated(val, file),
                        itemBuilder: (context) {
                          bool isQP = file.name.contains("_qp_");
                          bool isMS = file.name.contains("_ms_");
                          bool isGT = file.name.contains("_gt");
                          return [
                            if (!isQP && !isGT) const PopupMenuItem(value: "qp", child: Text("Open Question Paper")),
                            if (!isMS && !isGT) const PopupMenuItem(value: "ms", child: Text("Open Marking Scheme")),
                            if (!isGT) const PopupMenuItem(value: "gt", child: Text("Open Grade Threshold")),
                          ];
                        },
                      ),
                      Text(file.name, 
                        style: TextStyle(
                          fontSize: 11, 
                          color: isSelected ? Colors.white : Colors.grey, 
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        )
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => reader.closeTab(index), 
                        icon: const Icon(Icons.close, size: 14), 
                        constraints: const BoxConstraints(), 
                        padding: EdgeInsets.zero
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Listener(
            onPointerSignal: (e) => _handleScrollZoom(e, reader),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isQP = currentFile.name.contains("_qp_");
                return Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(color: Theme.of(context).scaffoldBackgroundColor),
                          IndexedStack(
                            index: reader.currentTabIndex,
                            children: reader.openFiles.asMap().entries.map((entry) {
                              int idx = entry.key;
                              var file = entry.value;
                              double viewerWidth = constraints.maxWidth;
                              if (file.zoom < 1.0) viewerWidth = constraints.maxWidth * file.zoom;

                              return Center(
                                child: SizedBox(
                                  width: viewerWidth,
                                  height: constraints.maxHeight,
                                  child: SfPdfViewer.file(
                                    File(file.path),
                                    key: ValueKey(file.path),
                                    controller: file.controller,
                                    interactionMode: PdfInteractionMode.pan,
                                    onPageChanged: (details) => reader.updatePageInfo(idx, details.newPageNumber, 0),
                                    onDocumentLoaded: (details) => reader.updatePageInfo(idx, 1, details.document.pages.count),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Positioned(
                            left: 25, bottom: 25,
                            child: _buildUniformCard(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text(
                                  "${currentFile.currentPage} / ${currentFile.totalPages}",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 25, bottom: 25,
                            child: _buildZoomCard(reader, currentFile),
                          ),
                        ],
                      ),
                    ),
                    if (isQP) ReaderSidePanel(fileName: currentFile.name),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUniformCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor.withAlpha(40)),
      ),
      child: child,
    );
  }

  Widget _buildZoomCard(ReaderController reader, OpenedFile file) {
    return _buildUniformCard(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _zoomBtn(Icons.add, () => reader.updateZoom(reader.currentTabIndex, file.zoom + 0.25)),
            Text("${(file.zoom * 100).round()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            _zoomBtn(Icons.remove, () => reader.updateZoom(reader.currentTabIndex, file.zoom - 0.25)),
          ],
        ),
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onPressed) {
    return IconButton(icon: Icon(icon, size: 20, color: Theme.of(context).primaryColor), onPressed: onPressed);
  }
}