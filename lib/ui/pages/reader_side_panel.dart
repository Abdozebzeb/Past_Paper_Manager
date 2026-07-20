import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/paper_data_service.dart';
import '../../services/grade_aesthetic_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../logic/log_model.dart';
import '../../services/log_service.dart';
import '../../logic/reader_controller.dart';

class ReaderSidePanel extends StatefulWidget {
  final String fileName;
  const ReaderSidePanel({super.key, required this.fileName});

  @override
  State<ReaderSidePanel> createState() => _ReaderSidePanelState();
}

class _ReaderSidePanelState extends State<ReaderSidePanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _marksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Sync UI with persistent state after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializePersistentState());
  }

  void _initializePersistentState() {
    final reader = Provider.of<ReaderController>(context, listen: false);
    if (reader.openFiles.isEmpty) return;

    final state = reader.openFiles[reader.currentTabIndex].panelState;
    
    // Only load from PDF/DB if we haven't already cached it for this file
    if (!state.isDataLoaded) {
      _fetchPaperDetails(state);
    } else {
      _marksController.text = state.scoredMarksInput;
    }
  }

  Future<void> _fetchPaperDetails(FilePanelState state) async {
    try {
      final data = await PaperDataService.getPaperDetails(widget.fileName);
      
      if (data.isNotEmpty && data['name'] != "Unknown Syllabus") {
        setState(() {
          state.paperName = data['name'] ?? "Unknown";
          state.paperCode = data['code'] ?? "Unknown";
          state.duration = data['duration'] ?? "0 minutes";
          state.rawMarks = data['raw'] ?? "-";
          state.thresholds = Map<String, String>.from(data['thresholds'] ?? {});
          
          // Set initial timer based on paper duration
          state.timerSeconds = _convertDurationToSeconds(state.duration);
          state.isDataLoaded = true;
        });
      } else {
        state.paperName = "Details Unavailable";
      }
    } catch (e) {
      debugPrint("Side Panel Data Load Error: $e");
    }
  }

  int _convertDurationToSeconds(String dur) {
    int totalSec = 0;
    final hMatch = RegExp(r"(\d+)\s*(?:hour|hr|h)", caseSensitive: false).firstMatch(dur);
    final mMatch = RegExp(r"(\d+)\s*(?:minute|min|m\b)", caseSensitive: false).firstMatch(dur);

    if (hMatch != null) totalSec += int.parse(hMatch.group(1)!) * 3600;
    if (mMatch != null) totalSec += int.parse(mMatch.group(1)!) * 60;
    
    return totalSec > 0 ? totalSec : 3600;
  }

  String _formatDuration(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    if (h > 0) return "${h}h ${m}m ${s}s";
    return "${m}m ${s}s";
  }

  void _toggleClock(FilePanelState state) {
    setState(() {
      state.isRunning = !state.isRunning;
    });
    // The actual ticking is managed by ReaderController's global ticker
  }

  void _editTimer(FilePanelState state) {
    int h = state.timerSeconds ~/ 3600;
    int m = (state.timerSeconds % 3600) ~/ 60;
    
    final TextEditingController hCtrl = TextEditingController(text: h.toString());
    final TextEditingController mCtrl = TextEditingController(text: m.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.blueAccent.withAlpha(25))),
        title: const Text("Set Custom Timer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 18)),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _editInput("Hours", hCtrl)),
            const SizedBox(width: 15),
            Expanded(child: _editInput("Minutes", mCtrl)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                state.timerSeconds = (int.tryParse(hCtrl.text) ?? 0) * 3600 + (int.tryParse(mCtrl.text) ?? 0) * 60;
                state.isRunning = false;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Set Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reader = Provider.of<ReaderController>(context);
    if (reader.openFiles.isEmpty) return const SizedBox.shrink();
    
    final state = reader.openFiles[reader.currentTabIndex].panelState;

    String calculatedGrade = "-";
    if (state.scoredMarksInput.isNotEmpty) {
      final int? marks = int.tryParse(state.scoredMarksInput);
      final int? max = int.tryParse(state.rawMarks);
      if (marks == null || marks < 0 || (max != null && marks > max)) {
        calculatedGrade = "X";
      } else {
        calculatedGrade = PaperDataService.calculateGrade(marks, state.thresholds);
      }
    }

    return Container(
      width: 320,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent.withAlpha(30)),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.black.withAlpha(40), borderRadius: BorderRadius.circular(16)),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(12)),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [Tab(text: "Info"), Tab(text: "Grading")],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScrollableTab(_buildInfoTab(state)), 
                _buildScrollableTab(_buildGradingTab(state, calculatedGrade))
              ],
            ),
          ),
          _buildClockCard(state),
        ],
      ),
    );
  }

  Widget _buildScrollableTab(Widget child) {
    return SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);
  }

  Widget _buildInfoTab(FilePanelState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoField("Paper Name", state.paperName),
        _infoField("Paper Code", state.paperCode),
        _infoField("Standard Duration", state.duration),
        _infoField("Raw Marks", state.rawMarks), 
        const SizedBox(height: 10),
        const Text("Grade Thresholds", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        const SizedBox(height: 12),
        _thresholdRow(state),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _thresholdRow(FilePanelState state) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withAlpha(15), 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueAccent.withAlpha(20))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: state.thresholds.entries.map((e) => Column(
          children: [
            Text(e.key, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 5),
            Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildGradingTab(FilePanelState state, String calculatedGrade) {
    bool showMessage = calculatedGrade == "-";
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: _marksController,
          onChanged: (val) => setState(() => state.scoredMarksInput = val),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            labelText: "Scored Marks",
            hintText: state.rawMarks != "-" ? "Max: ${state.rawMarks}" : "Enter marks",
            filled: true, fillColor: Colors.blueAccent.withAlpha(15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 30),
        const Text("Projected Grade", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 10),
        if (showMessage)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("Enter Your score to see your grade", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic)),
          )
        else
          Text(calculatedGrade, style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: GradeAestheticService.getGradeColor(calculatedGrade))),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: (calculatedGrade == "X" || calculatedGrade == "-") ? null : () async {
              String loggedDuration;
              int standardSec = _convertDurationToSeconds(state.duration);
              if (!state.isTimer && state.stopwatchSeconds > 0) {
                loggedDuration = _formatDuration(state.stopwatchSeconds);
              } else if (state.isTimer && state.timerSeconds < standardSec) {
                loggedDuration = _formatDuration(standardSec - state.timerSeconds);
              } else {
                loggedDuration = state.duration;
              }
              final newLog = PaperLog(
                id: const Uuid().v4(),
                dateCompleted: DateFormat('dd MMMM yyyy').format(DateTime.now()),
                duration: loggedDuration,
                code: state.paperCode,
                codeName: widget.fileName.replaceAll('.pdf', ''),
                year: widget.fileName.split('_')[1].substring(1),
                season: widget.fileName.split('_')[1].startsWith('s') ? "Summer" : "Winter",
                scoredMarks: int.tryParse(state.scoredMarksInput) ?? 0,
                rawMarks: int.tryParse(state.rawMarks) ?? 0,
                grade: calculatedGrade,
              );
              await LogService.saveLog(newLog);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paper Logged Successfully!")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text("Log Paper", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildClockCard(FilePanelState state) {
    int standardSec = _convertDurationToSeconds(state.duration);
    bool isTimeUp = state.isTimer && state.timerSeconds == 0 && standardSec > 0 && !state.isRunning;
    int displaySeconds = state.isTimer ? state.timerSeconds : state.stopwatchSeconds;

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blueAccent.withAlpha(20), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.blueAccent.withAlpha(30))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.isTimer ? "EXAM TIMER" : "STOPWATCH", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.1)),
              Visibility(
                visible: !state.isRunning,
                maintainSize: true, maintainAnimation: true, maintainState: true,
                child: Row(
                  children: [
                    Opacity(opacity: state.isTimer ? 1.0 : 0.0, child: IconButton(onPressed: state.isTimer ? () => _editTimer(state) : null, icon: const Icon(Icons.edit_calendar_outlined, size: 18, color: Colors.blueAccent))),
                    IconButton(onPressed: () => setState(() => state.isTimer = !state.isTimer), icon: const Icon(Icons.sync_alt_outlined, size: 18, color: Colors.blueAccent)),
                  ],
                ),
              ),
            ],
          ),
          InkWell(
            onTap: (state.isTimer && !state.isRunning) ? () => _editTimer(state) : null,
            child: FittedBox(
              child: Text(
                isTimeUp ? "TIME UP!" : "${(displaySeconds ~/ 3600).toString().padLeft(2, '0')}:${((displaySeconds % 3600) ~/ 60).toString().padLeft(2, '0')}:${(displaySeconds % 60).toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: isTimeUp ? Colors.redAccent : Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _clockBtn(state.isRunning ? Icons.pause : Icons.play_arrow, () => _toggleClock(state), state.isRunning ? Colors.orange : Colors.green),
              const SizedBox(width: 15),
              _clockBtn(Icons.refresh, () {
                setState(() { 
                  state.isRunning = false; 
                  if (state.isTimer) state.timerSeconds = _convertDurationToSeconds(state.duration); 
                  else state.stopwatchSeconds = 0;
                });
              }, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _clockBtn(IconData icon, VoidCallback tap, Color color) {
    return InkWell(onTap: tap, borderRadius: BorderRadius.circular(30), child: CircleAvatar(radius: 24, backgroundColor: color.withAlpha(25), child: Icon(icon, color: color, size: 22)));
  }

  Widget _infoField(String l, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: Colors.grey, fontSize: 10)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
  );

  Widget _editInput(String label, TextEditingController ctrl) {
    return Column(
      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.black.withAlpha(50), borderRadius: BorderRadius.circular(10)),
          child: TextField(controller: ctrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), decoration: const InputDecoration(border: InputBorder.none)),
        )
      ],
    );
  }
}