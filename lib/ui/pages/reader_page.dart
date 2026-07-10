import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../logic/reader_controller.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  double _zoomLevel = 1.0;
  // One controller for the current viewer.
  // (Ideally each tab should have its own controller.)
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    final reader = Provider.of<ReaderController>(context);

    if (reader.openFiles.isEmpty) {
      return const Center(
        child: Text("No papers are currently open in the reader."),
      );
    }

    return Column(
      children: [
        // =========================
        // Tab Bar
        // =========================
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
                    color: isSelected
                        ? Theme.of(context).scaffoldBackgroundColor
                        : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        reader.openFiles[index].name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.blueAccent : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => reader.closeTab(index),
                        icon: const Icon(Icons.close, size: 14),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        color: isSelected ? Colors.blueAccent : Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // =========================
        // PDF Viewer
        // =========================
        Expanded(
          child: Stack(
            children: [
              IndexedStack(
                index: reader.currentTabIndex,
                children: reader.openFiles.map((file) {
                  return SfPdfViewer.file(
                    File(file.path),
                    controller: _pdfViewerController,
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                    enableDoubleTapZooming: true,
                    interactionMode: PdfInteractionMode.selection,
                  );
                }).toList(),
              ),

              // Zoom Controls
              Positioned(
                right: 20,
                bottom: 20,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Zoom In",
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _zoomLevel = (_zoomLevel + 0.25).clamp(1.0, 5.0);
                              _pdfViewerController.zoomLevel = _zoomLevel;
                            });
                          },
                        ),
                        Text(
                          "${(_pdfViewerController.zoomLevel * 100).round()}%",
                          style: const TextStyle(fontSize: 11),
                        ),
                        IconButton(
                          tooltip: "Zoom Out",
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              _zoomLevel = (_zoomLevel - 0.25).clamp(1.0, 5.0);
                              _pdfViewerController.zoomLevel = _zoomLevel;
                            });
                          },
                        ),
                        const Divider(height: 10),
                        IconButton(
                          tooltip: "Reset Zoom",
                          icon: const Icon(Icons.fit_screen),
                          onPressed: () {
                            setState(() {
                              _zoomLevel = 1.0;
                              _pdfViewerController.zoomLevel = _zoomLevel;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
