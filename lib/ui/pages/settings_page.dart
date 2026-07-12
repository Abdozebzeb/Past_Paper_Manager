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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isProcessing = false;

  // --- PASTE YOUR FULL MARKDOWN HERE ---
  final String versionNotesContent = """
# Release Notes

---

# v2.0.0

**Release Type**: Major Release

Version 2.0.0 is a complete overhaul of CIE Past Paper Manager, introducing a redesigned architecture, integrated authentication, cloud-powered configuration, enhanced document management, and cross-platform support. This release focuses on improving performance, reliability, scalability, and the overall user experience.

---

## New Features

### Google Authentication
- Added secure Google Sign-In.
- Support for authentication on Windows and macOS.
- Automatic session restoration.
- Improved account sign-out handling.

### Built-in PDF Reader
- Added an integrated PDF reader.
- Open and view papers directly within the application.
- Multi-tab document support.
- Zoom controls and page navigation.
- Reader state persistence.

### Download Manager
- Completely redesigned download engine.
- Support for downloading multiple subjects in a single operation.
- Batch download functionality.
- Multiple download sources with automatic fallback.
- Improved download reliability and progress tracking.

### Remote Configuration
- Added Firebase-powered remote configuration.
- Download sources can now be updated remotely without requiring an application update.
- Remote data version management.

### User Analytics
- Added anonymous application analytics.
- Tracks:
  - Application launches
  - Download activity
  - Frequently opened papers
  - Feature usage
  - Last active time
- Device information is associated with authenticated users for application diagnostics.

### Library Management
- Introduced a provider-based library architecture.
- Faster file indexing and scanning.
- Automatic library refresh.
- Improved paper management.

### Theme Support
- Added Light and Dark themes.
- Theme preference is automatically saved.

### Terms and Privacy
- Added a first-run acknowledgement page.
- Users are required to accept the Terms and Privacy Policy before accessing the application.

### Cross-Platform Support
- Official support for Windows and macOS.
- Improved platform-specific storage management.
- Enhanced compatibility with packaged applications, including MSIX.

---

## Improvements

### Application Architecture
- Migrated to Provider-based state management.
- Improved separation between application logic, services, and user interface components.
- Simplified project structure for improved maintainability.

### Storage Management
- Migrated application data to the operating system's Application Support directory.
- Improved compatibility with packaged applications.
- Automatic creation and management of application data folders.

### Performance
- Reduced application startup time.
- Improved caching mechanisms.
- Reduced unnecessary disk operations.
- Improved state synchronization throughout the application.

### User Experience
- Redesigned authentication workflow.
- Improved onboarding experience.
- Streamlined navigation.
- Automatic switching to the integrated reader when opening documents.
- Enhanced download progress reporting.

---

## Bug Fixes

- Fixed Windows authentication persistence issues.
- Resolved the Windows "ghost login" issue after application reinstallation.
- Improved download reliability when a download source becomes unavailable.
- Fixed multiple reader synchronization issues.
- Improved first-run detection.
- Improved settings persistence.
- Addressed numerous stability and reliability issues.

---

## Developer Changes

### Added
- Authentication service
- Analytics service
- Configuration service
- Reader controller
- Library provider
- Settings provider

### Refactored
- Download engine
- State management
- Folder management
- Application initialization
- Navigation architecture

---

# v1.0.0

**Release Type:** Initial Release

The first public release of CIE Past Paper Manager, providing students with a streamlined desktop application for downloading, organizing, and accessing Cambridge International past papers.

---

## Features

### Past Paper Library
- Automatic scanning of locally stored past papers.
- Organize papers by:
  - Subject
  - Series
  - Year
  - Paper Type
  - Paper Number

### Download Manager
- Download Cambridge past papers directly from supported online repositories.
- Download progress tracking.
- Download status reporting.
- Support for:
  - Question Papers
  - Mark Schemes
  - Examiner Reports
  - Grade Thresholds

### Local File Management
- Automatic creation of the Past Papers directory.
- Quick access to the storage location.
- Refresh the paper library without restarting the application.

### Quick Actions
- Open selected papers directly from the application.
- Quickly access related documents, including:
  - Mark Schemes
  - Examiner Reports
  - Grade Thresholds

### Usage Analytics
- Anonymous application usage tracking.
- Download statistics.
- Basic application analytics.

### User Interface
- Modern desktop interface.
- Sidebar-based navigation.
- Responsive layout.
- Simplified workflow for browsing and accessing past papers.

---

## Technology Stack

- Flutter Desktop
- Firebase
- Cloud Firestore
- Shared Preferences
- HTTP Networking

---

## Known Limitations

- Windows-only support.
- Single download source.
- External PDF viewer required.
- No user authentication.
- No remote configuration support.
""";

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
          const SizedBox(height: 25),
          
          _sectionTitle("Account"),
          _settingsCard(
            ListTile(
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
            data: versionNotesContent, // Uses the variable defined at the top
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
              h1: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              listBullet: const TextStyle(color: Colors.blueAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Close", style: TextStyle(color: Colors.blueAccent))
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
            _infoRow("App Version", "2.0.0.0"),
            _infoRow("Version Release Date", "11/7/2026"),
            _infoRow("Build Type", "Release"),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); // Close sheet first
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
                  onPressed: () => _launchURL("https://github.com/Abdozebzeb"),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.instagram), 
                  onPressed: () => _launchURL("https://www.instagram.com/abdullahhzeb/"),
                ),
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