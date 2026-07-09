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
  // Initialize with one default job
  final List<DownloadJob> _jobs = [
    DownloadJob(
      subjects: [],
      startYear: 20,
      endYear: 25,
      papers: ["2", "4", "6"],
      variants: ["1", "2", "3"],
      types: ["qp", "ms"],
    )
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DownloadController>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Download Manager", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        children: [
          // Render each job card
          ..._jobs.asMap().entries.map((entry) => _buildJobCard(entry.key, entry.value)),

          const SizedBox(height: 10),

          // Fancy + Button (Centered, no text)
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _jobs.add(DownloadJob(
                    subjects: [],
                    startYear: 20,
                    endYear: 25,
                    papers: ["2", "4", "6"],
                    variants: ["1", "2", "3"],
                    types: ["qp", "ms"],
                  ))),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent.withAlpha(100)),
                ),
                child: const Icon(Icons.add, color: Colors.blueAccent, size: 30),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Progress Section
          if (controller.isDownloading)
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withAlpha(30)),
              ),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: controller.progress,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Downloading Papers: ${(controller.progress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),

          // Start All Button
          SizedBox(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
              ),
              onPressed: controller.isDownloading ? null : () => controller.runDownloads(_jobs),
              child: const Text(
                "Start All Downloads",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildJobCard(int index, DownloadJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent.withAlpha(50)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Download Job #${index + 1}",
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (index != 0)
                IconButton(
                  onPressed: () => setState(() => _jobs.removeAt(index)),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                )
            ],
          ),
          const Divider(height: 30, color: Colors.white10),
          
          // Subject Input
          _buildTextField(
            label: "Subject Codes (e.g., 9701, 9702)",
            hint: "Separate with commas",
            onChanged: (v) => job.subjects = v.split(',').map((e) => e.trim()).toList(),
          ),
          
          const SizedBox(height: 15),

          // Years Row
          Row(
            children: [
              Expanded(child: _buildTextField(label: "Start Year", hint: "20", onChanged: (v) => job.startYear = int.tryParse(v) ?? 20)),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField(label: "End Year", hint: "25", onChanged: (v) => job.endYear = int.tryParse(v) ?? 25)),
            ],
          ),

          const SizedBox(height: 15),

          // Papers and Variants Row
          Row(
            children: [
              Expanded(child: _buildTextField(label: "Papers", hint: "2, 4, 6", onChanged: (v) => job.papers = v.split(',').map((e) => e.trim()).toList())),
              const SizedBox(width: 15),
              Expanded(child: _buildTextField(label: "Variants", hint: "1, 2, 3", onChanged: (v) => job.variants = v.split(',').map((e) => e.trim()).toList())),
            ],
          ),

          const SizedBox(height: 20),

          // Types Checkboxes (The Restored GUI part)
          const Text("Include Types:", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTypeCheck("QP", "qp", job),
              _buildTypeCheck("MS", "ms", job),
              _buildTypeCheck("GT", "gt", job),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCheck(String label, String type, DownloadJob job) {
    bool isSelected = job.types.contains(type);
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              job.types.remove(type);
            } else {
              job.types.add(type);
            }
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? Colors.blueAccent : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 1)),
          ),
        ),
      ],
    );
  }
}