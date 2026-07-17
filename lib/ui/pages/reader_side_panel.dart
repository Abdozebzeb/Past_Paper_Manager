import 'package:flutter/material.dart';
import 'dart:async';

class ReaderSidePanel extends StatefulWidget {
  final String fileName;
  const ReaderSidePanel({super.key, required this.fileName});

  @override
  State<ReaderSidePanel> createState() => _ReaderSidePanelState();
}

class _ReaderSidePanelState extends State<ReaderSidePanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool isTimer = true;
  bool isRunning = false;
  int seconds = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _toggleClock() {
    if (isRunning) {
      _ticker?.cancel();
    } else {
      _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (isTimer && seconds > 0) {
            seconds--;
          } else if (!isTimer) {
            seconds++;
          } else {
            isRunning = false;
            _ticker?.cancel();
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

  @override
  Widget build(BuildContext context) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoField("Paper Name", "Pure Mathematics 1"),
        _infoField("Paper Code", "9709/12"),
        _infoField("Standard Duration", "1h 50m"),
        _infoField("Raw Marks", "75"), 
        const SizedBox(height: 10),
        const Text("Grade Thresholds", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        const SizedBox(height: 12),
        _thresholdRow(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _thresholdRow() {
    final Map<String, String> thresholds = {'A': '55', 'B': '48', 'C': '40', 'D': '32', 'E': '25'};
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
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            labelText: "Scored Marks",
            filled: true, fillColor: Colors.blueAccent.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 30),
        const Text("Projected Grade", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const Text("A", style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text("Log Paper", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildClockCard() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1))
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isTimer ? "EXAM TIMER" : "STOPWATCH", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.1)),
              IconButton(
                onPressed: () => setState(() { isTimer = !isTimer; seconds = 0; isRunning = false; _ticker?.cancel(); }),
                icon: const Icon(Icons.sync_alt_outlined, size: 18, color: Colors.blueAccent),
              )
            ],
          ),
          FittedBox(
            child: Text(
              "${(seconds ~/ 3600).toString().padLeft(2, '0')}:${((seconds % 3600) ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _clockBtn(isRunning ? Icons.pause : Icons.play_arrow, _toggleClock, isRunning ? Colors.orange : Colors.green),
              const SizedBox(width: 15),
              _clockBtn(Icons.refresh, () => setState(() { seconds = 0; isRunning = false; _ticker?.cancel(); }), Colors.grey),
            ],
          )
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