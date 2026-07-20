import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../logic/reader_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final reader = Provider.of<ReaderController>(context);
    if (reader.openFiles.isEmpty) return const Center(child: Text("No papers are currently open."));

    final currentFile = reader.openFiles[reader.currentTabIndex];

    return Column(
      children: [
        
        Container(
          height: 45,
          color: Theme.of(context).cardColor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reader.openFiles.length,
            itemBuilder: (context, index) {
              final isSelected = reader.currentTabIndex == index;
              return GestureDetector(
                onTap: () => reader.setTab(index),
                child: Container(
                  margin: const EdgeInsets.only(left: 8, top: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Text(reader.openFiles[index].name, 
                        style: TextStyle(
                          fontSize: 11, 
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey, 
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60), 
            blurRadius: 12, 
            offset: const Offset(0, 4)
          )
        ],
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4), 
              child: Text("${(file.zoom * 100).round()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
            ),
            _zoomBtn(Icons.remove, () => reader.updateZoom(reader.currentTabIndex, file.zoom - 0.25)),
            const Divider(height: 15, indent: 5, endIndent: 5),
            _zoomBtn(Icons.settings_backup_restore, () => reader.updateZoom(reader.currentTabIndex, 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20, color: Theme.of(context).primaryColor), 
      onPressed: onPressed, 
      constraints: const BoxConstraints(minWidth: 38, minHeight: 38), 
      padding: EdgeInsets.zero
    );
  }
}