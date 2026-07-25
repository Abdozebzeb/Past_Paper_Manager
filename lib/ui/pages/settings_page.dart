import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../logic/settings_provider.dart';
import '../../services/folder_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/accent_service.dart';
import '../../app_config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isProcessing = false;

  
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open link")),
        );
      }
    }
  }

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
          _sectionTitle("Personalization"),
          _settingsCard(
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent), 
              child: ExpansionTile(
                leading: Icon(Icons.palette_outlined, color: settings.current.primary),
                title: const Text("Color Accent"),
                subtitle: Text("Current: ${settings.accentName}", 
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: settings.current.subtle,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      // FIXED: Aligned the entries to the center
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: AccentService.palettes.keys.map((name) {
                        final pal = AccentService.getPalette(name, isDark);
                        bool isSelected = settings.accentName == name;
                        
                        return GestureDetector(
                          onTap: () => settings.setAccent(name),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60,
                                height: 45,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? pal.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Container(decoration: BoxDecoration(color: pal.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4))))),
                                    Expanded(child: Container(color: pal.surface)),
                                    Expanded(child: Container(decoration: BoxDecoration(color: pal.primary, borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4))))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(name, style: TextStyle(
                                fontSize: 10, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? settings.current.primary : Colors.grey
                              )),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          _sectionTitle("Data Management"),
          _settingsCard(
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.unarchive, color: Theme.of(context).primaryColor),
                  title: const Text("Export Library"),
                  subtitle: const Text("Backup your papers to a folder"),
                  onTap: _handleExport,
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  leading: Icon(Icons.system_update_alt, color: Theme.of(context).primaryColor),
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
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                title: const Text("About Manager"),
                onTap: () => _showAboutSheet(context),
              ),
            ),
          ),
          const SizedBox(height: 25),
          
          _sectionTitle("Account"),
          _settingsCard(
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                subtitle: const Text("Sign out of your Google Account"),
                onTap: () async {
                  await AuthService().signOut(); 
                  
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ),
          if (_isProcessing) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 10), child: Text(t, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 13)));

  Widget _settingsCard(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).primaryColor.withAlpha(30)),
    ),
    child: Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias, // Ensures the ripple stays inside the corners
      child: child,
    ),
  );

  Widget _colorPalette(String name, List<Color> shades) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50, height: 30, 
            clipBehavior: Clip.antiAlias, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: shades.map((c) => Expanded(child: Container(color: c))).toList(),
            ),
          ),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }
  void _showVersionNotes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Version Notes"),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Markdown(
            data: AppConfig.versionNotes, 
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
              h1: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              listBullet: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Close", style: TextStyle(color: Theme.of(context).primaryColor))
          )
        ],
      ),
    );
  }

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
            _infoRow("App Version", AppConfig.appVersion),
            _infoRow("Version Release Date", AppConfig.versionReleaseDate),
            //_infoRow("Patch Release Date", AppConfig.patchReleaseDate),
            _infoRow("Build Type", AppConfig.buildType),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); 
                  _showVersionNotes(context);
                },
                child: const Text("View Version Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.github), 
                  onPressed: () => _launchURL(AppConfig.githubUrl),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.instagram), 
                  onPressed: () => _launchURL(AppConfig.instaUrl),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey)), Text(v, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))]));

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