import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/folder_service.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({Key? key}) : super(key: key);

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  bool _isProcessing = false;

  // ================= EXPORT LOGIC =================
  Future<void> _handleExport() async {
    String? destinationPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select Export Destination",
    );

    if (destinationPath == null) return;

    setState(() => _isProcessing = true);

    try {
      final String sourcePath = FolderService.getPastPapersPath();
      final Directory sourceDir = Directory(sourcePath);

      if (!await sourceDir.exists()) {
        _showSnackBar("No papers found in library to export.");
        setState(() => _isProcessing = false);
        return;
      }

      int copiedCount = 0;
      final List<FileSystemEntity> files = sourceDir.listSync();

      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          final String fileName = file.path.split(Platform.pathSeparator).last;
          final String newPath = "$destinationPath${Platform.pathSeparator}$fileName";
          await file.copy(newPath);
          copiedCount++;
        }
      }
      _showSnackBar("Exported $copiedCount papers to $destinationPath");
    } catch (e) {
      _showSnackBar("Export failed: $e");
    }
    setState(() => _isProcessing = false);
  }

  // ================= IMPORT LOGIC =================
  Future<void> _handleImport() async {
    String? sourcePath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select Folder to Import From",
    );

    if (sourcePath == null) return;

    setState(() => _isProcessing = true);

    try {
      final String appLibraryPath = FolderService.getPastPapersPath();
      final Directory sourceDir = Directory(sourcePath);
      final Directory libDir = Directory(appLibraryPath);
      
      if (!await libDir.exists()) {
        await libDir.create(recursive: true);
      }

      int importedCount = 0;
      int skippedCount = 0;
      final List<FileSystemEntity> files = sourceDir.listSync();

      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          final String fileName = file.path.split(Platform.pathSeparator).last;
          final String destinationFile = "$appLibraryPath${Platform.pathSeparator}$fileName";

          if (!await File(destinationFile).exists()) {
            await file.copy(destinationFile);
            importedCount++;
          } else {
            skippedCount++;
          }
        }
      }

      String message = "Imported $importedCount papers.";
      if (skippedCount > 0) message += " ($skippedCount already existed).";
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Import failed: $e");
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: const Text("Data Management"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _managementCard(
              title: "Backup & Export",
              subtitle: "Copy your downloaded papers to an external folder.",
              icon: Icons.unarchive_rounded,
              buttonLabel: _isProcessing ? "Processing..." : "Select Folder & Export",
              onPressed: _isProcessing ? null : _handleExport,
            ),
            
            const SizedBox(height: 20),

            _managementCard(
              title: "Restore & Import",
              subtitle: "Add papers from your PC into the app library.",
              icon: Icons.system_update_alt_rounded,
              buttonLabel: _isProcessing ? "Processing..." : "Select Folder & Import",
              onPressed: _isProcessing ? null : _handleImport,
            ),
            
            const SizedBox(height: 40),
            
            Text(
              "Internal Path: ${FolderService.getPastPapersPath()}",
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
              textAlign: TextAlign.center,
            ),

            // ADDED FOOTER HERE
            const SizedBox(height: 60),
            const Text(
              "Created with ❤️ for Students By Abdullah Zeb",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }

  Widget _managementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonLabel,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161D2D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 28),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.withAlpha(30),
                foregroundColor: Colors.blueAccent,
                side: const BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onPressed,
              child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
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
}