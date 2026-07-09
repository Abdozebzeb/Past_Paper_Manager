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
      return const Center(child: Text("No papers are currently open."));
    }

    return Column(
      children: [
        Container(
          height: 45,
          color: Theme.of(context).cardColor.withOpacity(0.5),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reader.openFiles.length,
            itemBuilder: (context, index) {
              bool isSelected = reader.currentTabIndex == index;
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
                      Text(reader.openFiles[index].name, style: TextStyle(fontSize: 12, color: isSelected ? Colors.blueAccent : Colors.grey)),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => reader.closeTab(index),
                        icon: const Icon(Icons.close, size: 14),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: reader.currentTabIndex,
            children: reader.openFiles.map((file) => SfPdfViewer.file(File(file.path))).toList(),
          ),
        ),
      ],
    );
  }
}