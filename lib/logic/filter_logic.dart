import 'paper_model.dart';

class FilterLogic {
  static List<String> getSubjects(List<Paper> papers) {
    return papers.map((e) => e.subject).toSet().toList();
  }

  static List<String> getSeries(List<Paper> papers, String subject) {
    return papers
        .where((p) => p.subject == subject)
        .map((e) => e.series)
        .toSet()
        .toList();
  }

  static List<String> getYears(List<Paper> papers, String subject, String series) {
    return papers
        .where((p) => p.subject == subject && p.series == series)
        .map((e) => e.year)
        .toSet()
        .toList();
  }

  static List<String> getTypes(List<Paper> papers, String subject, String series, String year) {
    return papers
        .where((p) =>
            p.subject == subject &&
            p.series == series &&
            p.year == year)
        .map((e) => e.type)
        .toSet()
        .toList();
  }

  static List<String> getPapers(List<Paper> papers, String subject, String series, String year, String type) {
    return papers
        .where((p) =>
            p.subject == subject &&
            p.series == series &&
            p.year == year &&
            p.type == type &&
            p.paper != null)
        .map((e) => e.paper!)
        .toSet()
        .toList();
  }
}