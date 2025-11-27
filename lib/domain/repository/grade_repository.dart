import '../entity/grade_entity.dart';

abstract class GradeRepository {
  Future<List<GradeEntity>> getAllGrades();
  Future<GradeEntity?> getGradeById(String id);
  Future<List<GradeEntity>> getGradesByStudent(String studentId);
  Future<List<GradeEntity>> getGradesBySubject(String subject);
  Future<List<GradeEntity>> getGradesByTeacher(String teacherId);
  Future<double> getAverageGradeByStudent(String studentId);
  Future<double> getAverageGradeBySubject(String subject);
  Future<void> addGrade(GradeEntity grade);
  Future<void> updateGrade(GradeEntity grade);
  Future<void> deleteGrade(String id);
}
