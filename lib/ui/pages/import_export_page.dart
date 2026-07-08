import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/folder_service.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  bool _isProcessing = false;

  Future<void> _handleExport() async {
    String? dest = await FilePicker.platform.getDirectoryPath(dialogTitle: "Select Export Destination");
    if (dest == null) return;
    setState(() => _isProcessing = true);
    try {
      final String source = await FolderService.getPastPapersPath();
      final Directory sourceDir = Directory(source);
      if (await sourceDir.exists()) {
        final files = sourceDir.listSync();
        for (var file in files) {
          if (file is File && file.path.endsWith('.pdf')) {
            final name = file.path.split(Platform.pathSeparator).last;
            await file.copy("$dest${Platform.pathSeparator}$name");
          }
        }
        _showSnackBar("Export Complete");
      }
    } catch (e) { _showSnackBar("Error: $e"); }
    setState(() => _isProcessing = false);
  }

  Future<void> _handleImport() async {
    String? source = await FilePicker.platform.getDirectoryPath(dialogTitle: "Select Folder to Import");
    if (source == null) return;
    setState(() => _isProcessing = true);
    try {
      final String libraryPath = await FolderService.getPastPapersPath();
      final Directory sourceDir = Directory(source);
      final files = sourceDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          final name = file.path.split(Platform.pathSeparator).last;
          await file.copy("$libraryPath${Platform.pathSeparator}$name");
        }
      }
      _showSnackBar("Import Complete");
    } catch (e) { _showSnackBar("Error: $e"); }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Data Management"), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card("Export Library", "Backup files to your PC", Icons.unarchive, _handleExport),
            const SizedBox(height: 20),
            _card("Import Files", "Add files from your PC", Icons.system_update_alt, _handleImport),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String sub, IconData icon, VoidCallback action) {
    return Card(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title), subtitle: Text(sub),
        trailing: _isProcessing ? const CircularProgressIndicator() : const Icon(Icons.chevron_right),
        onTap: _isProcessing ? null : action,
      ),
    );
  }

  void _showSnackBar(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }
}