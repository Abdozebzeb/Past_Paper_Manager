import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../logic/reader_controller.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  
  
  
  
  double _virtualZoom = 0.8;

  void _updateZoom(double newZoom) {
    setState(() {
      _virtualZoom = newZoom.clamp(0.3, 5.0); 
      
      
      if (_virtualZoom >= 1.0) {
        _pdfViewerController.zoomLevel = _virtualZoom;
      } else {
        
        _pdfViewerController.zoomLevel = 1.0;
      }
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (HardwareKeyboard.instance.isControlPressed) {
        double delta = event.scrollDelta.dy < 0 ? 0.1 : -0.1;
        _updateZoom(_virtualZoom + delta);
      }
    }
  }

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
                        style: TextStyle(fontSize: 11, color: isSelected ? Colors.blueAccent : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => reader.closeTab(index),
                        icon: const Icon(Icons.close, size: 14),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
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
            onPointerSignal: _handlePointerSignal,
            child: LayoutBuilder(
              builder: (context, constraints) {
                
                
                double viewerWidth = constraints.maxWidth;
                if (_virtualZoom < 1.0) {
                  viewerWidth = constraints.maxWidth * _virtualZoom;
                }

                return Stack(
                  children: [
                    
                    Container(color: Theme.of(context).scaffoldBackgroundColor),
                    
                    
                    Center(
                      child: SizedBox(
                        width: viewerWidth,
                        height: constraints.maxHeight, 
                        child: IndexedStack(
  index: reader.currentTabIndex,
  children: reader.openFiles.map((file) {
    
    return SfPdfViewer.file(
      File(file.path),
      key: ValueKey(file.path), 
      controller: _pdfViewerController,
      enableDoubleTapZooming: true,
      interactionMode: PdfInteractionMode.pan,
    );
  }).toList(),
),
                      ),
                    ),

                    
                    Positioned(
                      right: 25,
                      bottom: 25,
                      child: _buildZoomCard(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoomCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withAlpha(40)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _zoomBtn(Icons.add, () => _updateZoom(_virtualZoom + 0.25)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "${(_virtualZoom * 100).round()}%",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            _zoomBtn(Icons.remove, () => _updateZoom(_virtualZoom - 0.25)),
            const Divider(height: 15, indent: 5, endIndent: 5),
            _zoomBtn(Icons.settings_backup_restore, () => _updateZoom(0.8)),
          ],
        ),
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20, color: Colors.blueAccent),
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      padding: EdgeInsets.zero,
      splashRadius: 20,
    );
  }
}