import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../logic/reader_controller.dart';

class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reader = Provider.of<ReaderController>(context);

    if (reader.openFiles.isEmpty) {
      return const Center(child: Text("No PDFs open. Select a paper to read."));
    }

    return Column(
      children: [
        // Tab Bar
        Container(
          height: 40,
          color: Theme.of(context).cardColor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reader.openFiles.length,
            itemBuilder: (context, index) {
              bool isSelected = reader.currentTabIndex == index;
              return GestureDetector(
                onTap: () => reader.setTab(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
                    border: Border(bottom: BorderSide(color: isSelected ? Colors.blueAccent : Colors.transparent, width: 2)),
                  ),
                  child: Row(
                    children: [
                      Text(reader.openFiles[index].name, style: TextStyle(fontSize: 12, color: isSelected ? Colors.blueAccent : Colors.grey)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => reader.closeTab(index),
                        child: const Icon(Icons.close, size: 14, color: Colors.grey),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // PDF View
        Expanded(
          child: SfPdfViewer.file(
            File(reader.openFiles[reader.currentTabIndex].path),
          ),
        ),
      ],
    );
  }
}