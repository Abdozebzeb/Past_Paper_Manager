import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../logic/downloader.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> with AutomaticKeepAliveClientMixin {
  static final ValueNotifier<double> _progressNotifier = ValueNotifier(0);
  static final ValueNotifier<bool> _isDownloadingNotifier = ValueNotifier(false);
  static final List<String> _staticSuccess = [];
  static final List<String> _staticFailed = [];

  
  final List<TextEditingController> _subjectControllers = [TextEditingController()];
  
  final startYearController = TextEditingController();
  final endYearController = TextEditingController();
  final papersController = TextEditingController();
  final variantsController = TextEditingController();

  Map<String, bool> types = {"qp": true, "ms": false, "gt": false};

  @override
  bool get wantKeepAlive => true;

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  void initState() {
    super.initState();
    _progressNotifier.addListener(_rebuild);
    _isDownloadingNotifier.addListener(_rebuild);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _sectionCard(
              title: "Download Setup",
              child: Column(
                children: [
                  
                  const Text("Subject Codes", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  ..._subjectControllers.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: _input("Example: 9701", entry.value)),
                          IconButton(
                            icon: Icon(entry.key == 0 ? Icons.add_circle : Icons.remove_circle, 
                                       color: Colors.blueAccent),
                            onPressed: () {
                              setState(() {
                                if (entry.key == 0) {
                                  _subjectControllers.add(TextEditingController());
                                } else {
                                  _subjectControllers.removeAt(entry.key);
                                }
                              });
                            },
                          )
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 30, color: Colors.white10),
                  Row(
                    children: [
                      Expanded(child: _input("Start Year (20)", startYearController)),
                      const SizedBox(width: 10),
                      Expanded(child: _input("End Year (25)", endYearController)),
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
                  const SizedBox(height: 20),
                  Wrap(
                    children: types.keys.map((key) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(value: types[key], activeColor: Colors.blueAccent, 
                                 onChanged: (v) => setState(() => types[key] = v!)),
                        Text(key.toUpperCase()),
                        const SizedBox(width: 20),
                      ],
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isDownloadingNotifier,
                    builder: (context, isDownloading, _) => SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        onPressed: isDownloading ? null : _startDownload,
                        child: Text(isDownloading ? "Downloading Batch..." : "Start Download Job", 
                                    style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _progressSection(),
          ],
        ),
      ),
    );
  }

  void _startDownload() async {
    _isDownloadingNotifier.value = true;
    _progressNotifier.value = 0;
    _staticSuccess.clear();
    _staticFailed.clear();

    final subjects = _subjectControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    final startYear = int.tryParse(startYearController.text) ?? 20;
    final endYear = int.tryParse(endYearController.text) ?? 25;
    final papers = papersController.text.split(',').map((e) => e.trim()).toList();
    final variants = variantsController.text.split(',').map((e) => e.trim()).toList();
    final selectedTypes = types.entries.where((e) => e.value).map((e) => e.key).toList();

    await Downloader.downloadPapers(
      subjects: subjects,
      startYear: startYear,
      endYear: endYear,
      papers: papers,
      variants: variants,
      types: selectedTypes,
      onProgress: (p) => _progressNotifier.value = p,
      onSuccess: (file) { _staticSuccess.add(file); setState(() {}); },
      onFail: (file) { _staticFailed.add(file); setState(() {}); },
    );
    _isDownloadingNotifier.value = false;
  }

  Widget _progressSection() {
    return ValueListenableBuilder<double>(
      valueListenable: _progressNotifier,
      builder: (context, progress, _) => _sectionCard(
        title: "Progress Status",
        child: Column(
          children: [
            LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(5)),
            const SizedBox(height: 10),
            Text("Success: ${_staticSuccess.length} | Failed: ${_staticFailed.length}"),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        child
      ]),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label, filled: true, fillColor: Colors.black12,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}