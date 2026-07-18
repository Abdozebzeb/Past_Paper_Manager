import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../logic/log_model.dart';
import '../../services/log_service.dart';
import '../../services/paper_data_service.dart';
import '../../services/grade_aesthetic_service.dart';

class PaperLogsPage extends StatefulWidget {
  const PaperLogsPage({super.key});
  @override
  State<PaperLogsPage> createState() => _PaperLogsPageState();
}

class _PaperLogsPageState extends State<PaperLogsPage> {
  List<PaperLog> _allLogs = [];
  List<PaperLog> _filteredLogs = [];
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadLogs() async {
    final logs = await LogService.getAllLogs();
    setState(() {
      _allLogs = logs;
      _filteredLogs = logs;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _filteredLogs = _allLogs.where((log) => 
        log.code.toLowerCase().contains(_searchController.text.toLowerCase()) || 
        log.codeName.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _filteredLogs = _allLogs;
      _searchController.clear();
    });
  }

  

  void _showManualLogDialog() {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedDuration = const TimeOfDay(hour: 1, minute: 45);
    String selectedSeason = "Summer";
    String codeName = "____ ___ qp __";
    String calculatedGrade = "-";
    
    final TextEditingController codeCtrl = TextEditingController();
    final TextEditingController yearCtrl = TextEditingController();
    final TextEditingController marksCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          
          Future<void> updateCalculations() async {
            String code = codeCtrl.text;
            String year = yearCtrl.text;
            String s = selectedSeason[0].toLowerCase();
            
            if (code.length == 7 && year.length == 2) {
              var parts = code.split('/');
              String newCodeName = "${parts[0]}_$s${year}_qp_${parts[1]}";
              
              
              final details = await PaperDataService.getPaperDetails("${newCodeName}.pdf");
              int? marks = int.tryParse(marksCtrl.text);
              
              setDialogState(() {
                codeName = newCodeName;
                if (marks != null && details['thresholds'] != null) {
                  calculatedGrade = PaperDataService.calculateGrade(marks, details['thresholds']);
                }
              });
            }
          }

          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.blueAccent.withOpacity(0.1))),
            title: const Text("Manual Paper Log", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: _dialogInput("Date Completed", InkWell(
                        onTap: () async {
                          final d = await _pickDate(context, selectedDate);
                          if (d != null) setDialogState(() => selectedDate = d);
                        },
                        child: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ))),
                      const SizedBox(width: 12),
                      Expanded(child: _dialogInput("Exam Duration", InkWell(
                        onTap: () async {
                          final t = await _pickTime(context);
                          if (t != null) setDialogState(() => selectedDuration = t);
                        },
                        child: Text("${selectedDuration.hour}h ${selectedDuration.minute}m", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _dialogInput("Code (9709/12)", TextField(
                        controller: codeCtrl, maxLength: 7,
                        onChanged: (val) {
                          if (val.length == 4 && !val.contains('/')) {
                            codeCtrl.text = "$val/";
                            codeCtrl.selection = TextSelection.fromPosition(TextPosition(offset: codeCtrl.text.length));
                          }
                          updateCalculations();
                        },
                        decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ))),
                      const SizedBox(width: 12),
                      Expanded(child: _dialogInput("Year (YY)", TextField(
                        controller: yearCtrl, maxLength: 2,
                        onChanged: (_) => updateCalculations(),
                        decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _dialogInput("Season", DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSeason, isExpanded: true, dropdownColor: Theme.of(context).cardColor,
                          items: ["Summer", "Winter", "March"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) { selectedSeason = val!; updateCalculations(); },
                        ),
                      ))),
                      const SizedBox(width: 12),
                      Expanded(child: _dialogInput("Raw Marks", TextField(
                        controller: marksCtrl,
                        onChanged: (_) => updateCalculations(),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: "00"),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ))),
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
                        _summaryRow("Calculated Grade", calculatedGrade, isBold: true, gradeColor: GradeAestheticService.getGradeColor(calculatedGrade)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Discard", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () async {
                  final newLog = PaperLog(
                    id: const Uuid().v4(),
                    dateCompleted: DateFormat('dd MMMM yyyy').format(selectedDate),
                    duration: "${selectedDuration.hour}h ${selectedDuration.minute}m",
                    code: codeCtrl.text,
                    codeName: codeName,
                    year: yearCtrl.text,
                    season: selectedSeason,
                    rawMarks: int.tryParse(marksCtrl.text) ?? 0,
                    grade: calculatedGrade,
                  );
                  await LogService.saveLog(newLog);
                  _loadLogs();
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Save Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Paper Logs", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [
          
          if (_allLogs.length != _filteredLogs.length)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off, size: 18, color: Colors.orangeAccent),
              label: const Text("Clear Filters", style: TextStyle(color: Colors.orangeAccent)),
            ),
          
          
          TextButton.icon(
            onPressed: () => setState(() {
              _selectionMode = !_selectionMode;
              _selectedIds.clear();
            }),
            icon: Icon(
              _selectionMode ? Icons.close : Icons.edit_note, 
              size: 18, 
              color: _selectionMode ? Colors.grey : Colors.blueAccent
            ),
            label: Text(
              _selectionMode ? "Cancel" : "Select Logs", 
              style: TextStyle(color: _selectionMode ? Colors.grey : Colors.blueAccent)
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          _buildTopActions(),
          const SizedBox(height: 25),
          _selectionMode && _selectedIds.isNotEmpty ? _buildDeleteBar() : _buildHeaders(),
          const SizedBox(height: 15),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  itemCount: _filteredLogs.length,
                  itemBuilder: (context, index) => _logTableRow(_filteredLogs[index]),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            height: 55, width: 170,
            child: ElevatedButton.icon(
              onPressed: _showManualLogDialog,
              icon: const Icon(Icons.add, size: 22),
              label: const Text("Log a Paper", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: SizedBox(
              height: 55,
              child: TextField(
                controller: _searchController,
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
    );
  }

  Widget _buildDeleteBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
      child: Row(
        children: [
          Text("${_selectedIds.length} records selected", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () async {
              await LogService.deleteLogs(_selectedIds.toList());
              setState(() { _selectionMode = false; _selectedIds.clear(); });
              _loadLogs();
            },
            icon: const Icon(Icons.delete_sweep, size: 18),
            label: const Text("Delete Logs"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildHeaders() {
    return Padding(
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
    );
  }

  Widget _prettyHeader(String label, {required int flex, required IconData icon, required String type}) {
    return Expanded(
      flex: flex,
      child: Builder(
        builder: (headerContext) => InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            if (type == 'date') {
               final d = await _pickDate(context, DateTime.now());
               if (d != null) {
                 setState(() {
                   String target = DateFormat('dd MMMM yyyy').format(d);
                   _filteredLogs = _allLogs.where((l) => l.dateCompleted == target).toList();
                 });
               }
            } else if (type != 'none') {
               final RenderBox button = headerContext.findRenderObject() as RenderBox;
               final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
               final RelativeRect position = RelativeRect.fromRect(
                 Rect.fromPoints(button.localToGlobal(Offset(0, button.size.height), ancestor: overlay), button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay)),
                 Offset.zero & overlay.size,
               );
               await showMenu(
                 context: context, position: position, color: Theme.of(context).cardColor,
                 constraints: const BoxConstraints(minWidth: 150),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.blueAccent.withOpacity(0.2))),
                 items: _getFilterItems(type),
               );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
                if (type != 'none' && type != 'date') const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry> _getFilterItems(String type) {
    if (type == 'sort') {
      return [
        PopupMenuItem(child: const Text("High to Low"), onTap: () => setState(() => _filteredLogs.sort((a, b) => b.rawMarks.compareTo(a.rawMarks)))),
        PopupMenuItem(child: const Text("Low to High"), onTap: () => setState(() => _filteredLogs.sort((a, b) => a.rawMarks.compareTo(b.rawMarks)))),
      ];
    }
    List<String> options = type == 'grade' ? ['A*', 'A', 'B', 'C', 'D', 'E', 'U'] : _allLogs.map((e) => e.code.split('/')[0]).toSet().toList();
    return options.map((o) => PopupMenuItem(
      onTap: () => setState(() => _filteredLogs = _allLogs.where((l) => type == 'grade' ? l.grade == o : l.code.startsWith(o)).toList()),
      child: Text(o),
    )).toList();
  }

  Widget _logTableRow(PaperLog log) {
    bool isSelected = _selectedIds.contains(log.id);
    return InkWell(
      onTap: _selectionMode ? () => setState(() => isSelected ? _selectedIds.remove(log.id) : _selectedIds.add(log.id)) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withOpacity(0.05) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            if (_selectionMode) ...[
              Checkbox(
                value: isSelected, 
                activeColor: Colors.blueAccent,
                onChanged: (v) => setState(() => v! ? _selectedIds.add(log.id) : _selectedIds.remove(log.id))
              ),
              const SizedBox(width: 10),
            ],
            Expanded(flex: 3, child: Text(log.dateCompleted, style: const TextStyle(fontSize: 13))),
            Expanded(flex: 2, child: Text(log.code, style: const TextStyle(fontWeight: FontWeight.bold))),
            Expanded(flex: 3, child: Text(log.codeName, style: const TextStyle(color: Colors.grey, fontSize: 12))),
            Expanded(flex: 2, child: Text("${log.rawMarks} / ${log.duration}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14))),
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: GradeAestheticService.getGradeColor(log.grade).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(log.grade, style: TextStyle(color: GradeAestheticService.getGradeColor(log.grade), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
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

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? gradeColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? (gradeColor ?? Colors.green) : Colors.white70)),
      ],
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) async {
    return await showDatePicker(
      context: context, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.dark(primary: Colors.blueAccent, surface: Theme.of(context).cardColor)),
        child: child!,
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context) async {
    return await showTimePicker(
      context: context, initialTime: const TimeOfDay(hour: 1, minute: 45),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.dark(primary: Colors.blueAccent, surface: Theme.of(context).cardColor)),
        child: child!,
      ),
    );
  }
}