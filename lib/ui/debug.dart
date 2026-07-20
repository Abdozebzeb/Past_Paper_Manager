import 'package:flutter/material.dart';
import '../services/folder_service.dart';

class DebugPanel extends StatelessWidget {
  final VoidCallback onRefresh;
  final String folderPath;

  const DebugPanel({
    Key? key,
    required this.onRefresh,
    required this.folderPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            "Add Your Files",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),

          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onRefresh,
                child: Text("Refresh Files"),
              ),

              ElevatedButton(
                onPressed: () {
                  FolderService.openFolder(folderPath);
                },
                child: Text("Open Folder to Add Files"),
              ),
            ],
          )
        ],
      ),
    );
  }
}