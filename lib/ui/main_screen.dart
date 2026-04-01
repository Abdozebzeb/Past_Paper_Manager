import 'package:flutter/material.dart';
import 'widgets/sidebar.dart';
import 'pages/view_papers_page.dart';
import 'pages/download_page.dart';
import 'pages/about_page.dart';
import 'pages/import_export_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // This list holds the different screens
  final List<Widget> _pages = [
    const ViewPapersPage(), // Your original filter screen
    const DownloadPage(),
    const ImportExportPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}