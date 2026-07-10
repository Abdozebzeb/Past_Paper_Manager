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
    
    // Log batch results
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
      appBar: AppBar(title: const Text("Download Manager"), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          ..._jobs.asMap().entries.map((entry) => _buildJobCard(entry.key, entry.value)),

          Center(
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 40),
              onPressed: () => setState(() => _jobs.add(DownloadJob(subjects: [], startYear: 20, endYear: 25, papers: ["2", "4", "6"], variants: ["1", "2", "3"], types: ["qp", "ms"]))),
            ),
          ),

          const SizedBox(height: 30),
          
          if (controller.isDownloading || controller.progress > 0)
            _sectionCard(
              title: "Progress",
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: controller.progress,
                    backgroundColor: Colors.white10,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                    color: controller.progress >= 1.0 ? Colors.green : Colors.blueAccent,
                  ),
                  const SizedBox(height: 10),
                  Text("${(controller.progress * 100).toStringAsFixed(0)}%", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: controller.progress >= 1.0 ? Colors.green : Colors.white)),
                ],
              ),
            ),

          const SizedBox(height: 20),

          _sectionCard(
            title: "Status Results",
            child: ExpansionTile(
              title: Row(
                children: [
                  Text("Success: ${_successList.length}", style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  Text("Failed: ${_failedList.length}", style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(onPressed: () => _copy(_failedList), child: const Text("Copy Failed")),
                    TextButton(onPressed: () => _copy(_successList), child: const Text("Copy Success")),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 30),
          
          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: controller.isDownloading ? null : _runAll,
              child: const Text("Start All Downloads", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _copy(List<String> list) {
    if (list.isEmpty) return;
    Clipboard.setData(ClipboardData(text: list.join("\n")));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  Widget _buildJobCard(int index, DownloadJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF161D2D), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Job #${index + 1}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              if (index != 0) IconButton(onPressed: () => setState(() => _jobs.removeAt(index)), icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18)),
            ],
          ),
          const SizedBox(height: 15),
          _input("Subject Codes (9701, 9702)", (v) => job.subjects = v.split(',').map((e) => e.trim()).toList()),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _input("Start Year (20)", (v) => job.startYear = int.tryParse(v) ?? 20)),
              const SizedBox(width: 10),
              Expanded(child: _input("End Year (25)", (v) => job.endYear = int.tryParse(v) ?? 25)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _input("Papers (2,4)", (v) => job.papers = v.split(',').map((e) => e.trim()).toList())),
              const SizedBox(width: 10),
              Expanded(child: _input("Variants (1,2)", (v) => job.variants = v.split(',').map((e) => e.trim()).toList())),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: ["qp", "ms", "gt"].map((t) => Row(
              children: [
                Checkbox(
                  value: job.types.contains(t),
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => v! ? job.types.add(t) : job.types.remove(t)),
                ),
                Text(t.toUpperCase(), style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 10),
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
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.grey, fontSize: 11),
        filled: true, fillColor: const Color(0xFF1A2335),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF161D2D), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blueAccent.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}