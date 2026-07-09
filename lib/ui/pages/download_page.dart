import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/downloader.dart';
import '../../logic/download_controller.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});
  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final List<DownloadJob> _jobs = [
    DownloadJob(subjects: [], startYear: 20, endYear: 25, papers: ["2","4","6"], variants: ["1","2","3"], types: ["qp", "ms"])
  ];

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
          
          const SizedBox(height: 10),
          Center(
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 40),
              onPressed: () => setState(() => _jobs.add(DownloadJob(subjects: [], startYear: 20, endYear: 25, papers: ["2","4","6"], variants: ["1","2","3"], types: ["qp", "ms"]))),
            ),
          ),
          
          const SizedBox(height: 30),
          if (controller.isDownloading) 
            Column(children: [
              LinearProgressIndicator(value: controller.progress),
              const SizedBox(height: 10),
              Text("${(controller.progress * 100).toStringAsFixed(0)}%", style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          
          const SizedBox(height: 20),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: controller.isDownloading ? null : () => controller.runDownloads(_jobs),
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.blueAccent.withAlpha(50))
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text("Job #${index + 1}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              if (index != 0) IconButton(onPressed: () => setState(() => _jobs.removeAt(index)), icon: const Icon(Icons.delete, color: Colors.redAccent))
            ]
          ),
          const SizedBox(height: 15),
          TextField(
            decoration: _inputDeco("Subject Codes (e.g. 9701, 9702)"), 
            onChanged: (v) => job.subjects = v.split(',').map((e) => e.trim()).toList()
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(decoration: _inputDeco("Start Yr"), onChanged: (v) => job.startYear = int.tryParse(v) ?? 20)),
            const SizedBox(width: 10),
            Expanded(child: TextField(decoration: _inputDeco("End Yr"), onChanged: (v) => job.endYear = int.tryParse(v) ?? 25)),
          ]),
          const SizedBox(height: 10),
          TextField(decoration: _inputDeco("Papers (2, 4)"), onChanged: (v) => job.papers = v.split(',').map((e) => e.trim()).toList()),
          const SizedBox(height: 10),
          TextField(decoration: _inputDeco("Variants (1, 2)"), onChanged: (v) => job.variants = v.split(',').map((e) => e.trim()).toList()),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String l) => InputDecoration(
    labelText: l, 
    labelStyle: const TextStyle(color: Colors.grey, fontSize: 12), 
    filled: true, 
    fillColor: Colors.black12, 
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
  );
}