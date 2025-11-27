import '../model/assignment.dart';
import '../source/hive_service.dart';

class AssignmentService {
  Future<List<Assignment>> getAllAssignments() async {
    final box = HiveService.getAssignmentBox();
    return box.values.map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<Assignment?> getAssignmentById(String id) async {
    final box = HiveService.getAssignmentBox();
    final assignmentMap = box.get(id);
    if (assignmentMap != null) {
      return Assignment.fromMap(Map<String, dynamic>.from(assignmentMap));
    }
    return null;
  }

  Future<List<Assignment>> getAssignmentsByTeacher(String teacherId) async {
    final box = HiveService.getAssignmentBox();
    final assignments = box.values.map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
    return assignments.where((assignment) => assignment.teacherId == teacherId).toList();
  }

  Future<List<Assignment>> getAssignmentsBySubject(String subject) async {
    final box = HiveService.getAssignmentBox();
    final assignments = box.values.map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
    return assignments.where((assignment) => assignment.subject == subject).toList();
  }

  Future<List<Assignment>> getAssignmentsByClass(String className) async {
    final box = HiveService.getAssignmentBox();
    final assignments = box.values.map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
    return assignments.where((assignment) => assignment.className == className).toList();
  }

  Future<List<Assignment>> getUpcomingAssignments() async {
    final box = HiveService.getAssignmentBox();
    final assignments = box.values.map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
    final now = DateTime.now();
    return assignments.where((assignment) {
      final dueDate = DateTime.parse(assignment.dueDate);
      return dueDate.isAfter(now);
    }).toList();
  }

  Future<List<Assignment>> getOverdueAssignments() async {
    final box = HiveService.getAssignmentBox();
    final assignments = box.values.map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
    final now = DateTime.now();
    return assignments.where((assignment) {
      final dueDate = DateTime.parse(assignment.dueDate);
      return dueDate.isBefore(now);
    }).toList();
  }

  Future<void> addAssignment(Assignment assignment) async {
    final box = HiveService.getAssignmentBox();
    await box.put(assignment.id, assignment.toMap());
  }

  Future<void> updateAssignment(Assignment assignment) async {
    final box = HiveService.getAssignmentBox();
    await box.put(assignment.id, assignment.toMap());
  }

  Future<void> deleteAssignment(String id) async {
    final box = HiveService.getAssignmentBox();
    await box.delete(id);
  }
}
