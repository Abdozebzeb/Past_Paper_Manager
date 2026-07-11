import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../logic/settings_provider.dart';
import '../../services/folder_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    bool isDark = settings.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Settings"), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          _sectionTitle("Appearance"),
          _settingsCard(
            ListTile(
              title: const Text("Theme Mode"),
              subtitle: Text(isDark ? "Dark Mode Enabled" : "Light Mode Enabled"),
              trailing: Switch(value: isDark, onChanged: (v) => settings.toggleTheme(v)),
            ),
          ),
          const SizedBox(height: 25),
          _sectionTitle("Data Management"),
          _settingsCard(
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.unarchive, color: Colors.blueAccent),
                  title: const Text("Export Library"),
                  subtitle: const Text("Backup your papers to a folder"),
                  onTap: _handleExport,
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.system_update_alt, color: Colors.blueAccent),
                  title: const Text("Import Papers"),
                  subtitle: const Text("Add PDF files from your PC"),
                  onTap: _handleImport,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _sectionTitle("Support"),
          _settingsCard(
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
              title: const Text("About Manager"),
              onTap: () => _showAboutSheet(context),
            ),
          ),
          if (_isProcessing) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 10), child: Text(t, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13)));

  Widget _settingsCard(Widget child) => Container(
    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withAlpha(30))),
    child: child,
  );

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("CIE Past Paper Manager", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Created by Abdullah Zeb", style: TextStyle(color: Colors.grey)),
            const Divider(height: 40, color: Colors.white10),
                    _infoRow("App Version", "2.0.0.0"),
                    _infoRow("Version Release Date", "11/7/2026"),
                    _infoRow("Build Type", "Release (Windows)"),
                    
                    
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const FaIcon(FontAwesomeIcons.github), onPressed: () {}),
                IconButton(icon: const FaIcon(FontAwesomeIcons.instagram), onPressed: () {}),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey)), Text(v, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))]));

  
  Future<void> _handleExport() async {
    String? dest = await FilePicker.platform.getDirectoryPath();
    if (dest == null) return;
    setState(() => _isProcessing = true);
    final String source = await FolderService.getPastPapersPath();
    final files = Directory(source).listSync();
    for (var f in files) if (f is File) await f.copy("$dest${Platform.pathSeparator}${f.path.split(Platform.pathSeparator).last}");
    setState(() => _isProcessing = false);
  }

  Future<void> _handleImport() async {
    String? source = await FilePicker.platform.getDirectoryPath();
    if (source == null) return;
    setState(() => _isProcessing = true);
    final String lib = await FolderService.getPastPapersPath();
    final files = Directory(source).listSync();
    for (var f in files) if (f is File && f.path.endsWith(".pdf")) await f.copy("$lib${Platform.pathSeparator}${f.path.split(Platform.pathSeparator).last}");
    setState(() => _isProcessing = false);
  }
}