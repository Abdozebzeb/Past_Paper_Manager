import 'package:flutter/material.dart';

class AccentPalette {
  final String name;
  final Color primary;    // Buttons, Icons, Active elements
  final Color surface;    // Card backgrounds
  final Color background; // Scaffold background
  final Color subtle;     // Borders or subtle highlights

  AccentPalette({
    required this.name,
    required this.primary,
    required this.surface,
    required this.background,
    required this.subtle,
  });
}

class AccentService {
  static Map<String, dynamic> palettes = {
    "Ocean Blue": {
      "dark": AccentPalette(
        name: "Ocean Blue",
        primary: const Color(0xFF448AFF),
        surface: const Color(0xFF161D2D),
        background: const Color(0xFF0A0F1C),
        subtle: const Color(0xFF448AFF).withOpacity(0.1),
      ),
      "light": AccentPalette(
        name: "Ocean Blue",
        primary: const Color(0xFF1976D2),
        surface: Colors.white,
        background: const Color(0xFFF5F7FA),
        subtle: const Color(0xFF1976D2).withOpacity(0.05),
      ),
    },
    "Sunset Red": {
      "dark": AccentPalette(
        name: "Sunset Red",
        primary: const Color(0xFFFF5252),
        surface: const Color(0xFF251616),
        background: const Color(0xFF150A0A),
        subtle: const Color(0xFFFF5252).withOpacity(0.1),
      ),
      "light": AccentPalette(
        name: "Sunset Red",
        primary: const Color(0xFFD32F2F),
        surface: Colors.white,
        background: const Color(0xFFFFF5F5),
        subtle: const Color(0xFFD32F2F).withOpacity(0.05),
      ),
    },
    "Forest Green": {
      "dark": AccentPalette(
        name: "Forest Green",
        primary: const Color(0xFF69F0AE),
        surface: const Color(0xFF16251C),
        background: const Color(0xFF0A150F),
        subtle: const Color(0xFF69F0AE).withOpacity(0.1),
      ),
      "light": AccentPalette(
        name: "Forest Green",
        primary: const Color(0xFF388E3C),
        surface: Colors.white,
        background: const Color(0xFFF5FFF6),
        subtle: const Color(0xFF388E3C).withOpacity(0.05),
      ),
    },
    "Royal Purple": {
      "dark": AccentPalette(
        name: "Royal Purple",
        primary: const Color(0xFFE040FB),
        surface: const Color(0xFF1D162D),
        background: const Color(0xFF110A1C),
        subtle: const Color(0xFFE040FB).withOpacity(0.1),
      ),
      "light": AccentPalette(
        name: "Royal Purple",
        primary: const Color(0xFF7B1FA2),
        surface: Colors.white,
        background: const Color(0xFFF9F5FA),
        subtle: const Color(0xFF7B1FA2).withOpacity(0.05),
      ),
    },
  };

  static AccentPalette getPalette(String name, bool isDark) {
    String themeKey = isDark ? "dark" : "light";
    return (palettes[name]?[themeKey]) ?? palettes["Ocean Blue"][themeKey];
  }
}