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
    if (_db != null) return;
    final libPath = await FolderService.getPastPapersPath();
    final dbPath = p.join(libPath, 'TimeTable.db');

    
    if (!File(dbPath).existsSync()) {
      final url = "https://abdozebzeb.github.io/CIE-Dates-Data/TimeTable.db";
      final response = await http.get(Uri.parse(url));
      await File(dbPath).writeAsBytes(response.bodyBytes);
    }

    if (Platform.isWindows || Platform.isMacOS) {
      databaseFactory = databaseFactoryFfi;
    }
    _db = await openDatabase(dbPath);
  }

  static Future<Map<String, dynamic>> getPaperDetails(String fileName) async {
    await _initDb();
    
    
    
    final reg = RegExp(r"(\d{4})_([smw])(\d{2})_qp_(\d{2})");
    final match = reg.firstMatch(fileName);
    if (match == null) return {};

    String syllabus = match.group(1)!;
    String suffix = match.group(4)!;
    String paperCode = "$syllabus/$suffix";

    
    String paperName = "Unknown Syllabus";
    final List<Map<String, dynamic>> maps = await _db!.query(
      'exam_timetable',
      where: 'code = ?',
      whereArgs: [paperCode],
      limit: 1,
    );
    if (maps.isNotEmpty) paperName = maps[0]['syllabus_name'];

    
    final libPath = await FolderService.getPastPapersPath();
    final qpPath = p.join(libPath, fileName);
    final gtName = fileName.replaceAll(RegExp(r"_qp_\d{2}"), "_gt");
    final gtPath = p.join(libPath, gtName);

    
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

    String duration = "Not Found";
    Map<String, String> thresholds = {'A': '-', 'B': '-', 'C': '-', 'D': '-', 'E': '-'};
    String rawMarks = "-";

    
    if (File(qpPath).existsSync()) {
      final PdfDocument document = PdfDocument(inputBytes: File(qpPath).readAsBytesSync());
      String text = PdfTextExtractor(document).extractText(startPageIndex: 0, endPageIndex: 0);
      final durMatch = RegExp(r"(\d+\s*hour[s]?\s*\d*\s*minute[s]?|\d+\s*minute[s]?)", caseSensitive: false).firstMatch(text);
      if (durMatch != null) duration = durMatch.group(1)!;
      document.dispose();
    }

    
    if (File(gtPath).existsSync()) {
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
    }

    return {
      'name': paperName,
      'code': paperCode,
      'duration': duration,
      'raw': rawMarks,
      'thresholds': thresholds
    };
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