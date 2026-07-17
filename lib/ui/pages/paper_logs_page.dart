import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaperLogsPage extends StatefulWidget {
  const PaperLogsPage({super.key});
  @override
  State<PaperLogsPage> createState() => _PaperLogsPageState();
}

class _PaperLogsPageState extends State<PaperLogsPage> {
  
  

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) async {
    return await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.blueAccent, 
            onPrimary: Colors.white,
            surface: Theme.of(context).cardColor, 
            onSurface: Colors.white70, 
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
          ),
        ),
        child: child!,
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 1, minute: 45),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.blueAccent,
            onSurface: Colors.white,
            surface: Theme.of(context).cardColor,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
          ),
        ),
        child: child!,
      ),
    );
  }

  

  void _showManualLogDialog() {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedDuration = const TimeOfDay(hour: 1, minute: 45);
    String selectedSeason = "Summer";
    String codeName = "____ ___ qp __";
    
    final TextEditingController codeCtrl = TextEditingController();
    final TextEditingController yearCtrl = TextEditingController();
    final TextEditingController marksCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          
          void updateCodeName() {
            String code = codeCtrl.text;
            String year = yearCtrl.text;
            String s = selectedSeason[0].toLowerCase();
            if (code.length == 7 && code.contains('/') && year.isNotEmpty) {
              var parts = code.split('/');
              codeName = "${parts[0]}_$s${year}_qp_${parts[1]}";
            } else {
              codeName = "Invalid Data";
            }
            setDialogState(() {});
          }

          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), 
              side: BorderSide(color: Colors.blueAccent.withOpacity(0.1)), 
            ),
            title: const Text("Manual Paper Log", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _dialogInput("Date Completed", InkWell(
                        onTap: () async {
                          final d = await _pickDate(context, selectedDate);
                          if (d != null) setDialogState(() => selectedDate = d);
                        },
                        child: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogInput("Exam Duration", InkWell(
                        onTap: () async {
                          final t = await _pickTime(context);
                          if (t != null) setDialogState(() => selectedDuration = t);
                        },
                        child: Text("${selectedDuration.hour}h ${selectedDuration.minute}m", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _dialogInput("Code (9709/12)", TextField(
                        controller: codeCtrl, maxLength: 7,
                        onChanged: (val) {
                          if (val.length == 4 && !val.contains('/')) {
                            codeCtrl.text = "$val/";
                            codeCtrl.selection = TextSelection.fromPosition(TextPosition(offset: codeCtrl.text.length));
                          }
                          updateCodeName();
                        },
                        decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogInput("Year (YY)", TextField(
                        controller: yearCtrl, maxLength: 2,
                        onChanged: (_) => updateCodeName(),
                        decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _dialogInput("Season", DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSeason, isExpanded: true, dropdownColor: Theme.of(context).cardColor,
                          items: ["Summer", "Winter", "March"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) { selectedSeason = val!; updateCodeName(); },
                        ),
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogInput("Raw Marks", TextField(
                        controller: marksCtrl,
                        decoration: const InputDecoration(border: InputBorder.none, hintText: "00"),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      _summaryRow("Generated File Name", codeName),
                      const SizedBox(height: 8),
                      _summaryRow("Calculated Grade", "A", isBold: true),
                    ],
                  ),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Discard", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Save Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dialogInput(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: child,
        )
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.green : Colors.white70)),
      ],
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Paper Logs", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  height: 55, width: 170,
                  child: ElevatedButton.icon(
                    onPressed: _showManualLogDialog,
                    icon: const Icon(Icons.add, size: 22),
                    label: const Text("Log a Paper", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search your examination history...",
                        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent, size: 20),
                        filled: true, fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: Row(
              children: [
                _prettyHeader("Date", flex: 3, icon: Icons.calendar_today, type: 'date'),
                _prettyHeader("Syllabus", flex: 2, icon: Icons.tag, type: 'filter'),
                _prettyHeader("Code Name", flex: 3, icon: Icons.description, type: 'none'),
                _prettyHeader("Marks", flex: 2, icon: Icons.bar_chart, type: 'sort'),
                _prettyHeader("Grade", flex: 1, icon: Icons.workspace_premium, type: 'grade'),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              itemCount: 8,
              itemBuilder: (context, index) => _logTableRow(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prettyHeader(String label, {required int flex, required IconData icon, required String type}) {
    return Expanded(
      flex: flex,
      child: Builder(
        builder: (headerContext) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                if (type == 'date') {
                  await _pickDate(context, DateTime.now());
                } else if (type != 'none') {
                  
                  final RenderBox button = headerContext.findRenderObject() as RenderBox;
                  final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                  
                  
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );

                  if (!mounted) return;

                  await showMenu(
                    context: context,
                    position: position,
                    color: Theme.of(context).cardColor,
                    useRootNavigator: true,
                    constraints: const BoxConstraints(minWidth: 150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), 
                      side: BorderSide(color: Colors.blueAccent.withOpacity(0.2))
                    ),
                    items: _getFilterItems(type),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
                    if (type != 'none' && type != 'date') const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white38),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  
  List<PopupMenuEntry> _getFilterItems(String type) {
    if (type == 'sort') {
      return [
        const PopupMenuItem(child: Text("High to Low", style: TextStyle(fontSize: 13))),
        const PopupMenuItem(child: Text("Low to High", style: TextStyle(fontSize: 13))),
      ];
    }

    List<String> options = type == 'grade' 
        ? ['A*', 'A', 'B', 'C', 'D', 'E', 'U'] 
        : ['9709', '9702', '9701', '0450'];

    return options.map((o) => PopupMenuItem(
      child: StatefulBuilder(
        builder: (context, setMenuState) => Row(
          children: [
            SizedBox(
              height: 24, width: 24,
              child: Checkbox(
                value: true, 
                activeColor: Colors.blueAccent,
                onChanged: (v) => setMenuState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Text(o, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    )).toList();
  }

  Widget _logTableRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Expanded(flex: 3, child: Text("12 July 2026", style: TextStyle(fontSize: 13))),
          const Expanded(flex: 2, child: Text("9702/42", style: TextStyle(fontWeight: FontWeight.bold))),
          const Expanded(flex: 3, child: Text("9702_w23_qp_42", style: TextStyle(color: Colors.grey, fontSize: 12))),
          const Expanded(flex: 2, child: Text("82 / 100", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14))),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: const Text("A*", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}