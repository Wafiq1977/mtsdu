import '../../domain/repository/grade_repository.dart';
import '../../domain/entity/grade_entity.dart';
import '../model/grade.dart' as model;
import '../source/hive_service.dart';

class GradeRepositoryImpl implements GradeRepository {
  @override
  Future<List<GradeEntity>> getAllGrades() async {
    final box = HiveService.getGradeBox();
    return box.values.map((e) => _mapModelToEntity(model.Grade.fromMap(Map<String, dynamic>.from(e)))).toList();
  }

  @override
  Future<GradeEntity?> getGradeById(String id) async {
    final box = HiveService.getGradeBox();
    final gradeMap = box.get(id);
    if (gradeMap != null) {
      return _mapModelToEntity(model.Grade.fromMap(Map<String, dynamic>.from(gradeMap)));
    }
    return null;
  }

  @override
  Future<List<GradeEntity>> getGradesByStudent(String studentId) async {
    final grades = await getAllGrades();
    return grades.where((grade) => grade.studentId == studentId).toList();
  }

  @override
  Future<List<GradeEntity>> getGradesBySubject(String subject) async {
    final grades = await getAllGrades();
    return grades.where((grade) => grade.subject == subject).toList();
  }

  @override
  Future<List<GradeEntity>> getGradesByTeacher(String teacherId) async {
    final grades = await getAllGrades();
    return grades.where((grade) => grade.teacherId == teacherId).toList();
  }

  @override
  Future<double> getAverageGradeByStudent(String studentId) async {
    final grades = await getGradesByStudent(studentId);
    if (grades.isEmpty) return 0.0;
    final total = grades.fold(0.0, (sum, grade) => sum + grade.score);
    return total / grades.length;
  }

  @override
  Future<double> getAverageGradeBySubject(String subject) async {
    final grades = await getGradesBySubject(subject);
    if (grades.isEmpty) return 0.0;
    final total = grades.fold(0.0, (sum, grade) => sum + grade.score);
    return total / grades.length;
  }

  @override
  Future<void> addGrade(GradeEntity grade) async {
    final box = HiveService.getGradeBox();
    await box.put(grade.id, _mapEntityToModel(grade).toMap());
  }

  @override
  Future<void> updateGrade(GradeEntity grade) async {
    final box = HiveService.getGradeBox();
    await box.put(grade.id, _mapEntityToModel(grade).toMap());
  }

  @override
  Future<void> deleteGrade(String id) async {
    final box = HiveService.getGradeBox();
    await box.delete(id);
  }

  GradeEntity _mapModelToEntity(model.Grade grade) {
    return GradeEntity(
      id: grade.id,
      studentId: grade.studentId,
      subject: grade.subject,
      assignment: grade.assignment,
      score: grade.score,
      date: grade.date,
      teacherId: grade.teacherId,
    );
  }

  model.Grade _mapEntityToModel(GradeEntity grade) {
    return model.Grade(
      id: grade.id,
      studentId: grade.studentId,
      subject: grade.subject,
      assignment: grade.assignment,
      score: grade.score,
      date: grade.date,
      teacherId: grade.teacherId,
    );
  }
}
