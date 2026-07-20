import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'folder_service.dart';
import 'config_service.dart';

class PaperDataService {
  static Database? _db;

  
  static Future<void> _initDb() async {
    if (_db != null && _db!.isOpen) return;
    final libPath = await FolderService.getPastPapersPath();
    final dbPath = p.join(libPath, 'TimeTable.db');

    if (!File(dbPath).existsSync()) {
      // Use the URL from ConfigService
      final url = ConfigService.timeTableUrl;
      final response = await http.get(Uri.parse(url));
      await File(dbPath).writeAsBytes(response.bodyBytes);
    }

    _db = await openDatabase(dbPath);
  }


  static Future<Map<String, dynamic>> getPaperDetails(String fileName) async {
    try {
      await _initDb();
      
      final reg = RegExp(r"(\d{4})_([smw])(\d{2})_qp_(\d{2})");
      final match = reg.firstMatch(fileName);
      if (match == null) return {};

      String syllabus = match.group(1)!;
      String suffix = match.group(4)!;
      String paperCode = "$syllabus/$suffix";

      String paperName = "Unknown Syllabus";
      String durationFromDb = "Not Found";
      
      final List<Map<String, dynamic>> maps = await _db!.query(
        'exam_timetable',
        where: 'code = ?',
        whereArgs: [paperCode],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        paperName = maps[0]['syllabus_name'] ?? "Unknown";
        // Extract duration from DB if column exists (assuming 'duration' column in your SQLite)
        durationFromDb = maps[0]['duration'] ?? "Not Found"; 
      }

      final libPath = await FolderService.getPastPapersPath();
      final gtName = fileName.replaceAll(RegExp(r"_qp_\d{2}"), "_gt");
      final gtPath = p.join(libPath, gtName);

      // Download GT if missing (Logic remains the same)
      if (!File(gtPath).existsSync()) {
        for (String basePath in ConfigService.downloadPaths) {
          try {
            final url = basePath.endsWith('/') ? "$basePath$gtName" : "$basePath/$gtName";
            final res = await http.get(Uri.parse(url));
            if (res.statusCode == 200) {
              await File(gtPath).writeAsBytes(res.bodyBytes);
              break;
            }
          } catch (_) {}
        }
      }

      Map<String, String> thresholds = {'A': '-', 'B': '-', 'C': '-', 'D': '-', 'E': '-'};
      String rawMarks = "-";

      // FAILSAFE: PDF Reading
      if (File(gtPath).existsSync()) {
        try {
          final PdfDocument document = PdfDocument(inputBytes: File(gtPath).readAsBytesSync());
          for (int i = 0; i < document.pages.count; i++) {
            String text = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
            final gtMatch = RegExp("Component\\s+$suffix\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)").firstMatch(text);
            if (gtMatch != null) {
              rawMarks = gtMatch.group(1)!;
              thresholds['A'] = gtMatch.group(2)!;
              thresholds['B'] = gtMatch.group(3)!;
              thresholds['C'] = gtMatch.group(4)!;
              thresholds['D'] = gtMatch.group(5)!;
              thresholds['E'] = gtMatch.group(6)!;
              break;
            }
          }
          document.dispose();
        } catch (e) {
          print("Failsafe: Could not read GT PDF: $e");
        }
      }

      return {
        'name': paperName,
        'code': paperCode,
        'duration': durationFromDb, // Now prioritizes DB
        'raw': rawMarks,
        'thresholds': thresholds
      };
    } catch (e) {
      print("Global Failsafe in getPaperDetails: $e");
      return {};
    }
  }

  static String calculateGrade(int marks, Map<String, String> thresholds) {
    try {
      if (marks >= int.parse(thresholds['A']!)) return "A";
      if (marks >= int.parse(thresholds['B']!)) return "B";
      if (marks >= int.parse(thresholds['C']!)) return "C";
      if (marks >= int.parse(thresholds['D']!)) return "D";
      if (marks >= int.parse(thresholds['E']!)) return "E";
      return "U";
    } catch (_) {
      return "N/A";
    }
  }
}