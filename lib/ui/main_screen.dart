import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/reader_controller.dart';
import 'pages/view_papers_page.dart';
import 'pages/download_page.dart';
import 'pages/settings_page.dart';
import 'pages/reader_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void switchToReader() {
  setState(() {
    _selectedIndex = 2; // Index of ReaderPage
  });
}
  int _selectedIndex = 0;

  Widget _getPage(int index, int readerIndex) {
    switch (index) {
      case 0: return const ViewPapersPage();
      case 1: return const DownloadPage();
      case 2: return const ReaderPage();
      case 3: return const SettingsPage();
      default: return const ViewPapersPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reader = Provider.of<ReaderController>(context);
    bool hasTabs = reader.openFiles.isNotEmpty;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 80,
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _navItem(Icons.library_books, 0, "Library"),
                _navItem(Icons.cloud_download, 1, "Download"),
                const Spacer(),
                if (hasTabs) _navItem(Icons.menu_book, 2, "Reader", badge: reader.openFiles.length),
                _navItem(Icons.settings, 3, "Settings"),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _getPage(_selectedIndex, 2)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label, {int? badge}) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Stack(
              children: [
                Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey, size: 28),
                if (badge != null && badge > 0)
                  Positioned(right: 0, child: CircleAvatar(radius: 7, backgroundColor: Colors.red, child: Text(badge.toString(), style: const TextStyle(fontSize: 9)))),
              ],
            ),
            Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.blueAccent : Colors.grey)),
          ],
        ),
      ),
    );
  }
}