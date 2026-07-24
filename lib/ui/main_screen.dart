import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/reader_controller.dart';
import 'pages/view_papers_page.dart';
import 'pages/download_page.dart';
import 'pages/settings_page.dart';
import 'pages/reader_page.dart';
import 'pages/paper_logs_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _getPage(int index) {
    switch (index) {
      case 0: return const ViewPapersPage();
      case 1: return const DownloadPage();
      case 2: return const ReaderPage();
      case 3: return const PaperLogsPage(); 
      case 4: return const SettingsPage(); 
      default: return const ViewPapersPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reader = Provider.of<ReaderController>(context);
    bool hasTabs = reader.openFiles.isNotEmpty;
    int currentIndex = reader.mainMenuIndex;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar - Restored to 80px width
          Container(
            width: 80,
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _navItem(Icons.library_books, 0, "Library", reader),
                _navItem(Icons.cloud_download, 1, "Download", reader),
                _navItem(Icons.history_edu, 3, "Logs", reader),
                const Spacer(),
                if (hasTabs) _navItem(Icons.menu_book, 2, "Reader", reader, badge: reader.openFiles.length),
                _navItem(Icons.settings, 4, "Settings", reader),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _getPage(currentIndex)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label, ReaderController reader, {int? badge}) {
    bool isSelected = reader.mainMenuIndex == index;
    
    return GestureDetector(
      onTap: () => reader.setMenuIndex(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Uniform size: 60x60 Rounded Square
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12), // Rounded Square (not a pill)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon, 
                    color: isSelected ? Colors.white : Colors.grey, 
                    size: 24
                  ),
                  if (badge != null && badge > 0)
                    Positioned(
                      top: -4, 
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          badge.toString(), 
                          style: TextStyle(
                            fontSize: 9, 
                            fontWeight: FontWeight.bold, 
                            color: isSelected ? Theme.of(context).primaryColor : Colors.white
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label, 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}