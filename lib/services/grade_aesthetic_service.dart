import 'package:flutter/material.dart';

class GradeAestheticService {
  static Color getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A*':
      case 'A':
        return Colors.greenAccent;
      case 'B':
        return Colors.lightGreenAccent;
      case 'C':
        return Colors.yellowAccent;
      case 'D':
        return Colors.orangeAccent;
      case 'E':
        return Colors.deepOrangeAccent;
      case 'U':
        return Colors.redAccent;
      case 'X':
        return Colors.grey;
      default:
        return Colors.white70;
    }
  }
}