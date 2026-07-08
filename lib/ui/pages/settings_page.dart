import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    bool isDark = settings.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Appearance", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: isDark,
                onChanged: (val) => settings.toggleTheme(val),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text("About", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            color: Theme.of(context).cardColor,
            child: const ListTile(
              title: Text("Version"),
              trailing: Text("2.0.0"),
            ),
          ),
        ],
      ),
    );
  }
}