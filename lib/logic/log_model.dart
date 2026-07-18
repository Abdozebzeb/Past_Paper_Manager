class PaperLog {
  final String id;
  final String dateCompleted;
  final String duration;
  final String code;
  final String codeName;
  final String year;
  final String season;
  final int rawMarks;
  final String grade;

  PaperLog({
    required this.id,
    required this.dateCompleted,
    required this.duration,
    required this.code,
    required this.codeName,
    required this.year,
    required this.season,
    required this.rawMarks,
    required this.grade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateCompleted': dateCompleted,
      'duration': duration,
      'code': code,
      'codeName': codeName,
      'year': year,
      'season': season,
      'rawMarks': rawMarks,
      'grade': grade,
    };
  }

  factory PaperLog.fromMap(Map<String, dynamic> map) {
    return PaperLog(
      id: map['id'],
      dateCompleted: map['dateCompleted'],
      duration: map['duration'],
      code: map['code'],
      codeName: map['codeName'],
      year: map['year'],
      season: map['season'],
      rawMarks: map['rawMarks'],
      grade: map['grade'],
    );
  }
}