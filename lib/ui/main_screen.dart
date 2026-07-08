import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/view_papers_page.dart';
import 'pages/download_page.dart';
import 'pages/about_page.dart';
import 'pages/import_export_page.dart';
import 'pages/settings_page.dart';
import 'pages/reader_page.dart';
import '../logic/reader_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ViewPapersPage(),
    const ReaderPage(),
    const DownloadPage(),
    const ImportExportPage(),
    const SettingsPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final reader = Provider.of<ReaderController>(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            backgroundColor: const Color(0xFF0D121F),
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            destinations: [
              const NavigationRailDestination(icon: Icon(Icons.library_books), label: Text("Library")),
              NavigationRailDestination(
                icon: Badge(
                  label: Text(reader.openFiles.length.toString()),
                  isLabelVisible: reader.openFiles.isNotEmpty,
                  child: const Icon(Icons.menu_book),
                ),
                label: const Text("Reader"),
              ),
              const NavigationRailDestination(icon: Icon(Icons.download), label: Text("Download")),
              const NavigationRailDestination(icon: Icon(Icons.swap_horiz), label: Text("Data")),
              const NavigationRailDestination(icon: Icon(Icons.settings), label: Text("Settings")),
              const NavigationRailDestination(icon: Icon(Icons.info), label: Text("About")),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}