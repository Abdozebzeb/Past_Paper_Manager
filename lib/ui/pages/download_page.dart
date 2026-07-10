import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../logic/downloader.dart';
import '../../logic/download_controller.dart';
import '../../services/analytics_service.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});
  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final List<DownloadJob> _jobs = [
    DownloadJob(subjects: [], startYear: 20, endYear: 25, papers: ["2", "4", "6"], variants: ["1", "2", "3"], types: ["qp", "ms"])
  ];

  final List<String> _successList = [];
  final List<String> _failedList = [];

  void _runAll() async {
    final controller = Provider.of<DownloadController>(context, listen: false);
    _successList.clear();
    _failedList.clear();

    await Downloader.downloadBatch(
      jobs: _jobs,
      onProgress: (p) => controller.updateProgress(p),
      onSuccess: (f) => setState(() => _successList.add(f)),
      onFail: (f) => setState(() => _failedList.add(f)),
    );
    
    final analytics = AnalyticsService();
    String? uid = await analytics.getStoredUserId();
    if (uid != null && _successList.isNotEmpty) {
      await analytics.logBatchDownloads(uid, _successList.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DownloadController>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Download Manager", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          ..._jobs.asMap().entries.map((entry) => _buildJobCard(entry.key, entry.value)),

          Center(
            child: IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.blueAccent.withOpacity(0.5), size: 32),
              onPressed: () => setState(() => _jobs.add(DownloadJob(subjects: [], startYear: 20, endYear: 25, papers: ["2", "4", "6"], variants: ["1", "2", "3"], types: ["qp", "ms"]))),
            ),
          ),

          const SizedBox(height: 30),
          
          
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _sectionCard(
                    title: "Progress",
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          value: controller.progress,
                          backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                          color: controller.progress >= 1.0 ? Colors.green : Colors.blueAccent,
                        ),
                        const SizedBox(height: 10),
                        Text("${(controller.progress * 100).toStringAsFixed(0)}%", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: controller.progress >= 1.0 ? Colors.green : Colors.blueAccent)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _sectionCard(
                    title: "Status Results",
                    child: ExpansionTile(
                      shape: const Border(),
                      tilePadding: EdgeInsets.zero,
                      title: Center(
                        child: Text(
                          "Success: ${_successList.length}  Failed: ${_failedList.length}", 
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                        ),
                      ),
                      children: [
                        _copyButton("Failed", _failedList, Colors.redAccent),
                        _copyButton("Success", _successList, Colors.green),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          
          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: controller.isDownloading ? null : _runAll,
              child: Text(controller.isDownloading ? "Downloading..." : "Start All Downloads", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _copyButton(String label, List<String> list, Color color) {
    return InkWell(
      onTap: () {
        if (list.isEmpty) return;
        Clipboard.setData(ClipboardData(text: list.join("\n")));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text("Copy $label", style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildJobCard(int index, DownloadJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Download Job #${index + 1}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              if (index != 0) IconButton(onPressed: () => setState(() => _jobs.removeAt(index)), icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
            ],
          ),
          const SizedBox(height: 20),
          _input("Subject Codes (9701, 9702)", (v) => job.subjects = v.split(',').map((e) => e.trim()).toList()),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _input("Start Year (20)", (v) => job.startYear = int.tryParse(v) ?? 20)),
              const SizedBox(width: 12),
              Expanded(child: _input("End Year (25)", (v) => job.endYear = int.tryParse(v) ?? 25)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _input("Papers (2,4,6)", (v) => job.papers = v.split(',').map((e) => e.trim()).toList())),
              const SizedBox(width: 12),
              Expanded(child: _input("Variants (1,2,3)", (v) => job.variants = v.split(',').map((e) => e.trim()).toList())),
            ],
          ),
          const SizedBox(height: 20),
          const Center(child: Text("Include Types:", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ["qp", "ms", "gt"].map((t) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: job.types.contains(t),
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => v! ? job.types.add(t) : job.types.remove(t)),
                ),
                Text(t.toUpperCase(), style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 15),
              ],
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _input(String label, Function(String) onCh) {
    return TextField(
      onChanged: onCh,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        filled: true, fillColor: Colors.blueAccent.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}