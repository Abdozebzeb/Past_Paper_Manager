import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
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
              // --- PROFILE CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2D),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withAlpha(75)),
                ),
                child: Column(
                  children: [
                    // const CircleAvatar(
                    //   radius: 40,
                    //   backgroundColor: Colors.blueAccent,
                    //   child: Icon(Icons.person, size: 50, color: Colors.white),
                    // ),
                    const SizedBox(height: 15),
                    const Text(
                      "Abdullah Zeb",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Yapper & Student",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const Divider(height: 30, color: Colors.white10),
                    
                    _infoRow("App Version", "1.0.2"),
                    _infoRow("Version Release Date", "1/4/2026"),
                    _infoRow("Build Type", "Release (Windows)"),
                    _infoRow("Latest Patch", "Patch #3"),
                    _infoRow("Patch Release Date", "2/4/2026"),

                    
                    const SizedBox(height: 20),
                    const Text(
                      "Version Notes:",
                      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
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

              // --- SOCIAL LINKS (HARDCODED TO AVOID TYPE ERRORS) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // GitHub Button
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.github, color: Colors.white70, size: 28),
                    onPressed: () => _launchURL(context, "https://github.com/Abdozebzeb"),
                    hoverColor: Colors.blueAccent.withAlpha(25),
                  ),
                  const SizedBox(width: 20),
                  // Instagram Button
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white70, size: 28),
                    onPressed: () => _launchURL(context, "https://www.instagram.com/abdullahhzeb/"),
                    hoverColor: Colors.blueAccent.withAlpha(25),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const Text(
                "Created with ❤️ for Students, By Abdullah Zeb",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A small helper for text is fine because String types never change
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}