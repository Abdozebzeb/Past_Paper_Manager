import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FolderService {
  static String? _cachedPath;

  static Future<String> getPastPapersPath() async {
    if (_cachedPath != null) return _cachedPath!;
    
    
    final directory = await getApplicationSupportDirectory();
    final path = p.join(directory.path, 'PastPapers');
    
    final folder = Directory(path);
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    
    _cachedPath = path;
    return path;
  }

  static void openFolder(String path) {
    if (Platform.isWindows) {
      Process.run('explorer', [path]);
    } else if (Platform.isMacOS) {
      Process.run('open', [path]);
    }
  }
}