import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).primaryColor.withAlpha(75)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Text("Abdullah Zeb", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text("Yapper & Student", style: TextStyle(color: Colors.grey)),
                    const Divider(height: 30, color: Colors.white10),

                    _infoRow(context, "App Version", "1.0.4.2"),
                    _infoRow(context, "Version Release Date", "2/5/2026"),
                    _infoRow(context, "Build Type", "Release (Windows)"),
                    _infoRow(context, "Latest Patch", "Patch #2"),
                    _infoRow(context, "Patch Release Date", "8/7/2026"),

                    const SizedBox(height: 20),
                    Text(
                      "Version Notes:",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Initial release with Sidebar Navigation, \nPaper Filtering, and Downloader Support.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.github, color: Colors.white70, size: 28),
                    onPressed: () => _launchURL(context, "https://github.com/Abdozebzeb"),
                    hoverColor: Theme.of(context).primaryColor.withAlpha(25),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white70, size: 28),
                    onPressed: () => _launchURL(context, "https://www.instagram.com/abdullahhzeb/"),
                    hoverColor: Theme.of(context).primaryColor.withAlpha(25),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}