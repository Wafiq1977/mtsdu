import '../model/grade.dart';
import '../source/hive_service.dart';

class GradeService {
  Future<List<Grade>> getAllGrades() async {
    final box = HiveService.getGradeBox();
    return box.values.map((e) => Grade.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<Grade?> getGradeById(String id) async {
    final box = HiveService.getGradeBox();
    final gradeMap = box.get(id);
    if (gradeMap != null) {
      return Grade.fromMap(Map<String, dynamic>.from(gradeMap));
    }
    return null;
  }

  Future<List<Grade>> getGradesByStudent(String studentId) async {
    final box = HiveService.getGradeBox();
    final grades = box.values.map((e) => Grade.fromMap(Map<String, dynamic>.from(e))).toList();
    return grades.where((grade) => grade.studentId == studentId).toList();
  }

  Future<List<Grade>> getGradesBySubject(String subject) async {
    final box = HiveService.getGradeBox();
    final grades = box.values.map((e) => Grade.fromMap(Map<String, dynamic>.from(e))).toList();
    return grades.where((grade) => grade.subject == subject).toList();
  }

  Future<List<Grade>> getGradesByTeacher(String teacherId) async {
    final box = HiveService.getGradeBox();
    final grades = box.values.map((e) => Grade.fromMap(Map<String, dynamic>.from(e))).toList();
    return grades.where((grade) => grade.teacherId == teacherId).toList();
  }

  Future<double> getAverageGradeByStudent(String studentId) async {
    final grades = await getGradesByStudent(studentId);
    if (grades.isEmpty) return 0.0;
    final total = grades.fold(0.0, (sum, grade) => sum + grade.score);
    return total / grades.length;
  }

  Future<double> getAverageGradeBySubject(String subject) async {
    final grades = await getGradesBySubject(subject);
    if (grades.isEmpty) return 0.0;
    final total = grades.fold(0.0, (sum, grade) => sum + grade.score);
    return total / grades.length;
  }

  Future<void> addGrade(Grade grade) async {
    final box = HiveService.getGradeBox();
    await box.put(grade.id, grade.toMap());
  }

  Future<void> updateGrade(Grade grade) async {
    final box = HiveService.getGradeBox();
    await box.put(grade.id, grade.toMap());
  }

  Future<void> deleteGrade(String id) async {
    final box = HiveService.getGradeBox();
    await box.delete(id);
  }
}
