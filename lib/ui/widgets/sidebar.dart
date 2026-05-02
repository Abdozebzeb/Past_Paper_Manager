import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isExtended;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isExtended = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: isExtended,
      backgroundColor: const Color(0xFF0D121F), 
      unselectedIconTheme: const IconThemeData(color: Colors.grey),
      selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      labelType: isExtended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books),
          label: Text("View"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.download_for_offline_outlined),
          selectedIcon: Icon(Icons.download_for_offline),
          label: Text("Download"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.unarchive_outlined),
          selectedIcon: Icon(Icons.unarchive),
          label: Text("Import/Export"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info),
          label: Text("About"),
        ),
      ],
    );
  }
}