import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../../services/paper_data_service.dart';
import '../../services/grade_aesthetic_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../logic/log_model.dart';
import '../../services/log_service.dart';

class ReaderSidePanel extends StatefulWidget {
  final String fileName;
  const ReaderSidePanel({super.key, required this.fileName});

  @override
  State<ReaderSidePanel> createState() => _ReaderSidePanelState();
}

class _ReaderSidePanelState extends State<ReaderSidePanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  
  bool _isLoading = true;
  String? _errorMessage;
  String paperName = "Loading...";
  String paperCode = "Loading...";
  String duration = "Loading...";
  String rawMarks = "-";
  Map<String, String> thresholds = {'A': '-', 'B': '-', 'C': '-', 'D': '-', 'E': '-'};
  
  String calculatedGrade = "-";
  final TextEditingController _marksController = TextEditingController();

  bool isTimer = true;
  bool isRunning = false;
  int seconds = 0;
  Timer? _ticker;

  int timerSeconds = 0;
  int stopwatchSeconds = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _editTimer() {
    int h = timerSeconds ~/ 3600;
    int m = (timerSeconds % 3600) ~/ 60;
    
    final TextEditingController hCtrl = TextEditingController(text: h.toString());
    final TextEditingController mCtrl = TextEditingController(text: m.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.blueAccent.withOpacity(0.1),
            width: 1.0,
          ),
        ),
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
              int newH = int.tryParse(hCtrl.text) ?? 0;
              int newM = int.tryParse(mCtrl.text) ?? 0;
              setState(() {
                timerSeconds = (newH * 3600) + (newM * 60);
                isRunning = false;
                _ticker?.cancel();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            child: const Text("Set Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _editInput(String label, TextEditingController ctrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        )
      ],
    );
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      final data = await PaperDataService.getPaperDetails(widget.fileName);
      
      if (data.isEmpty || data['name'] == "Unknown Syllabus") {
        throw Exception("Invalid data");
      }

      if (mounted) {
        setState(() {
          paperName = data['name'] ?? "Unknown";
          paperCode = data['code'] ?? "Unknown";
          duration = data['duration'] ?? "0 minutes";
          rawMarks = data['raw'] ?? "-";
          thresholds = data['thresholds'] ?? thresholds;
          _isLoading = false;
          _errorMessage = null;
          
          // Reset clocks
          isRunning = false;
          _ticker?.cancel();
          stopwatchSeconds = 0;
          
          // Initialize timer to standard duration
          int parsedSeconds = _convertDurationToSeconds(duration);
          timerSeconds = parsedSeconds; 
          isTimer = true; 
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Invalid or Unsupported PDF File.";
        });
      }
    }
  }

  // Improved parser for various duration formats
  int _convertDurationToSeconds(String dur) {
    int totalSec = 0;
    // Matches "1 hour", "1hr", "1 h"
    final hMatch = RegExp(r"(\d+)\s*(?:hour|hr|h)", caseSensitive: false).firstMatch(dur);
    // Matches "45 minutes", "45min", "45 m"
    final mMatch = RegExp(r"(\d+)\s*(?:minute|min|m\b)", caseSensitive: false).firstMatch(dur);

    if (hMatch != null) totalSec += int.parse(hMatch.group(1)!) * 3600;
    if (mMatch != null) totalSec += int.parse(mMatch.group(1)!) * 60;
    
    return totalSec > 0 ? totalSec : 3600; // Default to 1 hour if parsing fails
  }

  String _formatDuration(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    if (h > 0) return "${h}h ${m}m ${s}s";
    return "${m}m ${s}s";
  }

  void _parseDurationToSeconds(String dur) {
    int totalSec = 0;
    final hMatch = RegExp(r"(\d+)\s*hour").firstMatch(dur);
    final mMatch = RegExp(r"(\d+)\s*minute").firstMatch(dur);
    if (hMatch != null) totalSec += int.parse(hMatch.group(1)!) * 3600;
    if (mMatch != null) totalSec += int.parse(mMatch.group(1)!) * 60;
    if (totalSec > 0) setState(() => timerSeconds = totalSec);
  }

  void _onMarksChanged(String val) {
    if (val.isEmpty) {
      setState(() => calculatedGrade = "-");
      return;
    }

    final int? marks = int.tryParse(val);
    final int? maxMarks = int.tryParse(rawMarks);

    if (marks == null || marks < 0 || (maxMarks != null && marks > maxMarks)) {
      setState(() => calculatedGrade = "X");
    } else {
      setState(() => calculatedGrade = PaperDataService.calculateGrade(marks, thresholds));
    }
  }

  void _toggleClock() {
    if (isRunning) {
      _ticker?.cancel();
    } else {
      _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (isTimer) {
            if (timerSeconds > 0) {
              timerSeconds--;
            } else {
              isRunning = false;
              _ticker?.cancel();
              SystemSound.play(SystemSoundType.alert);
            }
          } else {
            stopwatchSeconds++;
          }
        });
      });
    }
    setState(() => isRunning = !isRunning);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildErrorScreen() {
    return Container(
      width: 320, margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.redAccent.withOpacity(0.2))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 20),
          Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text("Retry Load", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    return Container(
      width: 320,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(16)
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.blueAccent, 
                borderRadius: BorderRadius.circular(12)
              ),
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
                _buildScrollableTab(_buildInfoTab()), 
                _buildScrollableTab(_buildGradingTab())
              ],
            ),
          ),

          _buildClockCard(),
        ],
      ),
    );
  }

  Widget _buildScrollableTab(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: child,
    );
  }

  Widget _buildInfoTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoField("Paper Name", paperName),
        _infoField("Paper Code", paperCode),
        _infoField("Standard Duration", duration),
        _infoField("Raw Marks", rawMarks), 
        const SizedBox(height: 10),
        const Text("Grade Thresholds", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        const SizedBox(height: 12),
        _thresholdRow(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _thresholdRow() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: thresholds.entries.map((e) => Column(
          children: [
            Text(e.key, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 5),
            Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildGradingTab() {
    bool showMessage = calculatedGrade == "-";
    
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: _marksController,
          onChanged: _onMarksChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            labelText: "Scored Marks",
            hintText: rawMarks != "-" ? "Max: $rawMarks" : "Enter marks",
            filled: true, fillColor: Colors.blueAccent.withOpacity(0.05),
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
            child: Text(
              "Enter Your score to see your grade",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
            ),
          )
        else
          Text(
            calculatedGrade,
            style: TextStyle(
              fontSize: 64, 
              fontWeight: FontWeight.bold, 
              color: GradeAestheticService.getGradeColor(calculatedGrade),
            ),
          ),
          
        const SizedBox(height: 30),
        // Inside _buildGradingTab
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: (calculatedGrade == "X" || calculatedGrade == "-") ? null : () async {
              // Calculate dynamic duration for the log
              String loggedDuration;
              int standardSec = _convertDurationToSeconds(duration);

              if (!isTimer && stopwatchSeconds > 0) {
                // If stopwatch was used
                loggedDuration = _formatDuration(stopwatchSeconds);
              } else if (isTimer && timerSeconds < standardSec) {
                // If timer was used (Standard - Remaining)
                loggedDuration = _formatDuration(standardSec - timerSeconds);
              } else {
                // Default to standard duration string if no clock was used
                loggedDuration = duration;
              }

              final newLog = PaperLog(
                id: const Uuid().v4(),
                dateCompleted: DateFormat('dd MMMM yyyy').format(DateTime.now()),
                duration: loggedDuration,
                code: paperCode,
                codeName: widget.fileName.replaceAll('.pdf', ''),
                year: widget.fileName.split('_')[1].substring(1),
                season: widget.fileName.split('_')[1].startsWith('s') ? "Summer" : "Winter",
                scoredMarks: int.tryParse(_marksController.text) ?? 0,
                rawMarks: int.tryParse(rawMarks) ?? 0,
                grade: calculatedGrade,
              );

              await LogService.saveLog(newLog);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Paper Logged Successfully!"))
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Log Paper", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildClockCard() {
    // Only show "TIME UP" if timer is 0 AND we have a valid parsed duration > 0
    int standardSec = _convertDurationToSeconds(duration);
    bool isTimeUp = isTimer && timerSeconds == 0 && standardSec > 0 && !isRunning;
    int displaySeconds = isTimer ? timerSeconds : stopwatchSeconds;

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTimer ? "EXAM TIMER" : "STOPWATCH", 
                style: const TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.blueAccent, 
                  letterSpacing: 1.1,
                ),
              ),
              Visibility(
                visible: !isRunning,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Row(
                  children: [
                    Opacity(
                      opacity: isTimer ? 1.0 : 0.0,
                      child: IconButton(
                        onPressed: isTimer ? _editTimer : null, 
                        icon: const Icon(Icons.edit_calendar_outlined, size: 18, color: Colors.blueAccent),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => isTimer = !isTimer),
                      icon: const Icon(Icons.sync_alt_outlined, size: 18, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          InkWell(
            onTap: (isTimer && !isRunning) ? _editTimer : null,
            borderRadius: BorderRadius.circular(10),
            child: FittedBox(
              child: Text(
                isTimeUp ? "TIME UP!" : "${(displaySeconds ~/ 3600).toString().padLeft(2, '0')}:${((displaySeconds % 3600) ~/ 60).toString().padLeft(2, '0')}:${(displaySeconds % 60).toString().padLeft(2, '0')}",
                style: TextStyle(
                  fontSize: 42, 
                  fontWeight: FontWeight.bold, 
                  fontFamily: 'monospace',
                  color: isTimeUp ? Colors.redAccent : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _clockBtn(isRunning ? Icons.pause : Icons.play_arrow, _toggleClock, isRunning ? Colors.orange : Colors.green),
              const SizedBox(width: 15),
              _clockBtn(Icons.refresh, () {
                setState(() { 
                  isRunning = false; 
                  _ticker?.cancel(); 
                  if (isTimer) {
                    _parseDurationToSeconds(duration); 
                  } else {
                    stopwatchSeconds = 0;
                  }
                });
              }, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _clockBtn(IconData icon, VoidCallback tap, Color color) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(30),
      child: CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 22)),
    );
  }

  Widget _infoField(String l, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    ]),
  );
}