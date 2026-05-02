class Paper {
  final String subject;
  final String series;
  final String year;
  final String type;
  final String? paper;
  final String path;

  Paper({
    required this.subject,
    required this.series,
    required this.year,
    required this.type,
    this.paper,
    required this.path,
  });
}