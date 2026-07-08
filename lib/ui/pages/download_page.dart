import 'package:flutter/material.dart';
import '../../logic/downloader.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});
  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final List<DownloadJob> _jobs = [DownloadJob(subject: "", startYear: 20, endYear: 25, papers: ["2","4","6"], variants: ["1","2","3"], types: ["qp", "ms"])];
  bool _isDownloading = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Download Manager"), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          ..._jobs.asMap().entries.map((entry) => _buildJobCard(entry.key, entry.value)),
          const SizedBox(height: 10),
          TextButton.icon(onPressed: () => setState(() => _jobs.add(DownloadJob(subject: "", startYear: 20, endYear: 25, papers: ["2","4","6"], variants: ["1","2","3"], types: ["qp", "ms"]))), icon: const Icon(Icons.add), label: const Text("Add Another Download Job")),
          const SizedBox(height: 30),
          if (_isDownloading) Column(children: [LinearProgressIndicator(value: _progress), Text("${(_progress * 100).toStringAsFixed(0)}%")]),
          const SizedBox(height: 10),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _isDownloading ? null : _startAll,
              child: const Text("Start All Downloads", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildJobCard(int index, DownloadJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF161D2D), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withAlpha(50))),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Download Job #${index + 1}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)), if (index != 0) IconButton(onPressed: () => setState(() => _jobs.removeAt(index)), icon: const Icon(Icons.delete, color: Colors.redAccent))]),
          const SizedBox(height: 15),
          TextField(decoration: _inputDeco("Subject Code"), onChanged: (v) => job.subject = v),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: TextField(decoration: _inputDeco("Start Yr"), onChanged: (v) => job.startYear = int.tryParse(v) ?? 20)), const SizedBox(width: 10), Expanded(child: TextField(decoration: _inputDeco("End Yr"), onChanged: (v) => job.endYear = int.tryParse(v) ?? 25))]),
          const SizedBox(height: 10),
          TextField(decoration: _inputDeco("Papers (comma separated)"), onChanged: (v) => job.papers = v.split(',').map((e) => e.trim()).toList()),
          const SizedBox(height: 10),
          TextField(decoration: _inputDeco("Variants (comma separated)"), onChanged: (v) => job.variants = v.split(',').map((e) => e.trim()).toList()),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String l) => InputDecoration(labelText: l, labelStyle: const TextStyle(color: Colors.grey, fontSize: 12), filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none));

  void _startAll() async {
    setState(() { _isDownloading = true; _progress = 0; });
    await Downloader.downloadBatch(jobs: _jobs, onProgress: (p) => setState(() => _progress = p), onSuccess: (f) {}, onFail: (f) {});
    setState(() => _isDownloading = false);
  }
}