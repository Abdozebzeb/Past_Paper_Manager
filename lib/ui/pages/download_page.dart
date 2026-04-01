import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../logic/downloader.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> with AutomaticKeepAliveClientMixin {
  // Global-style Notifiers that stay alive in memory
  static final ValueNotifier<double> _progressNotifier = ValueNotifier(0);
  static final ValueNotifier<bool> _isDownloadingNotifier = ValueNotifier(false);
  static final List<String> _staticSuccess = [];
  static final List<String> _staticFailed = [];

  final subjectController = TextEditingController();
  final startYearController = TextEditingController();
  final endYearController = TextEditingController();
  final papersController = TextEditingController();
  final variantsController = TextEditingController();

  Map<String, bool> types = {"qp": true, "ms": false, "gt": false};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Listen to the broadcast even if we switch tabs and come back
    _progressNotifier.addListener(_rebuild);
    _isDownloadingNotifier.addListener(_rebuild);
  }

  @override
  void dispose() {
    // Clean up listeners to prevent memory leaks
    _progressNotifier.removeListener(_rebuild);
    _isDownloadingNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: const Text("Download Papers"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _sectionCard(
              title: "Download Setup",
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _input("Subject Code", subjectController)),
                      const SizedBox(width: 10),
                      Expanded(child: _input("Start Year", startYearController)),
                      const SizedBox(width: 10),
                      Expanded(child: _input("End Year", endYearController)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _input("Papers (2,4,6)", papersController)),
                      const SizedBox(width: 10),
                      Expanded(child: _input("Variants (1,2,3)", variantsController)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: types.keys.map((String key) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: types[key],
                            activeColor: Colors.blueAccent,
                            onChanged: (bool? value) {
                              setState(() => types[key] = value!);
                            },
                          ),
                          Text(key.toUpperCase(), style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 20),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isDownloadingNotifier,
                      builder: (context, isDownloading, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isDownloading ? null : startDownload,
                          child: Text(isDownloading ? "Downloading..." : "Start Download", 
                            style: const TextStyle(color: Colors.white)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _sectionCard(
                    title: "Progress",
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ValueListenableBuilder<double>(
                          valueListenable: _progressNotifier,
                          builder: (context, progress, child) {
                            return Column(
                              children: [
                                LinearProgressIndicator(
                                  backgroundColor: Colors.white10,
                                  value: progress,
                                  color: progress >= 1.0 ? Colors.green : Colors.blueAccent,
                                  minHeight: 8,
                                ),
                                const SizedBox(height: 10),
                                Text("${(progress * 100).toStringAsFixed(0)}%", 
                                  style: TextStyle(
                                    color: progress >= 1.0 ? Colors.green : Colors.white, 
                                    fontWeight: FontWeight.bold
                                  )),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 3,
                  child: _sectionCard(
                    title: "Status Results",
                    child: ExpansionTile(
                      iconColor: Colors.blueAccent,
                      collapsedIconColor: Colors.white,
                      title: Text(
                        "Success: ${_staticSuccess.length} | Failed: ${_staticFailed.length}",
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _copyButton("Copy Failed", _staticFailed),
                            _copyButton("Copy Success", _staticSuccess),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),
            // const Text(
            //   "Created with ❤️ for Students By Abdullah Zeb",
            //   style: TextStyle(color: Colors.grey, fontSize: 12),
            // )
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF161D2D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1A2335),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _copyButton(String label, List<String> data) {
    return TextButton(
      onPressed: () {
        if (data.isEmpty) return;
        Clipboard.setData(ClipboardData(text: data.join("\n")));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$label copied")));
      },
      child: Text(label, style: const TextStyle(color: Colors.blueAccent)),
    );
  }

  // --- LOGIC ---
  void startDownload() async {
    _isDownloadingNotifier.value = true;
    _progressNotifier.value = 0;
    _staticSuccess.clear();
    _staticFailed.clear();
    setState(() {}); // Clear local UI lists

    try {
      final subject = subjectController.text.trim();
      final startYear = int.parse(startYearController.text.trim());
      final endYear = int.parse(endYearController.text.trim());
      final papers = papersController.text.split(',').map((e) => e.trim()).toList();
      final variants = variantsController.text.split(',').map((e) => e.trim()).toList();
      final selectedTypes = types.entries.where((e) => e.value).map((e) => e.key).toList();

      await Downloader.downloadPapers(
        subject: subject,
        startYear: startYear,
        endYear: endYear,
        papers: papers,
        variants: variants,
        types: selectedTypes,
        onProgress: (p) => _progressNotifier.value = p,
        onSuccess: (file) {
          _staticSuccess.add(file);
          if (mounted) setState(() {});
        },
        onFail: (file) {
          _staticFailed.add(file);
          if (mounted) setState(() {});
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid input")));
      }
    }

    _isDownloadingNotifier.value = false;
  }
}