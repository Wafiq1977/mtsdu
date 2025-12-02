import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lpmmtsdu/domain/entity/attendance_entity.dart';
import '../../../data/model/schedule.dart';
import '../../../data/model/grade.dart';
import '../../../data/model/attendance.dart';
import '../../../data/model/assignment.dart';
import '../../../data/model/announcement.dart';
import '../../../data/model/payment.dart';
import '../../../data/model/calendar_event.dart'; // IMPORT BARU
import '../../../data/model/material.dart' as material_model; // IMPORT BARU
import '../../../domain/entity/schedule_entity.dart'; // IMPORT BARU
import '../../../data/source/hive_service.dart';
import '../../../data/model/material.dart' as material_model;

class DataProvider with ChangeNotifier {
  List<Schedule> _schedules = [];
  List<Grade> _grades = [];
  List<Attendance> _attendances = [];
  List<Assignment> _assignments = [];
  List<Announcement> _announcements = [];
  List<Payment> _payments = [];
  List<CalendarEvent> _calendarEvents = []; // TAMBAH INI
  List<material_model.Material> _materials = []; // TAMBAH INI

  // Getters
  List<Schedule> get schedules => _schedules;
  List<Grade> get grades => _grades;
  List<Attendance> get attendances => _attendances;
  List<Assignment> get assignments => _assignments;
  List<Announcement> get announcements => _announcements;
  List<Payment> get payments => _payments;
  List<CalendarEvent> get calendarEvents => _calendarEvents; // TAMBAH INI
  List<material_model.Material> get materials => _materials; // TAMBAH INI

  DataProvider() {
    _loadAllData();
  }

  void _loadAllData() {
    loadSchedules();
    loadGrades();
    loadAttendances();
    loadAssignments();
    loadAnnouncements();
    loadPayments();
    loadCalendarEvents();
    loadMaterials();
  }

  // === CALENDAR EVENTS METHODS ===
  void loadCalendarEvents() {
    try {
      final box = HiveService.getCalendarEventBox();
      _calendarEvents = box.values
          .map((e) => CalendarEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading calendar events: $e');
      _calendarEvents = [];
      notifyListeners();
    }
  }

  Future<void> addCalendarEvent(CalendarEvent event) async {
    try {
      final box = HiveService.getCalendarEventBox();
      await box.put(event.id, event.toMap());
      _calendarEvents.add(event);
      notifyListeners();
    } catch (e) {
      print('Error adding calendar event: $e');
      throw e;
    }
  }

  Future<void> updateCalendarEvent(CalendarEvent event) async {
    try {
      final box = HiveService.getCalendarEventBox();
      await box.put(event.id, event.toMap());
      final index = _calendarEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _calendarEvents[index] = event;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating calendar event: $e');
      throw e;
    }
  }

  Future<void> deleteCalendarEvent(String id) async {
    try {
      final box = HiveService.getCalendarEventBox();
      await box.delete(id);
      _calendarEvents.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting calendar event: $e');
      throw e;
    }
  }

  // === SCHEDULE METHODS ===
  void loadSchedules() {
    final box = HiveService.getScheduleBox();
    _schedules = box.values
        .map((e) => Schedule.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<void> addSchedule(Schedule schedule) async {
    final box = HiveService.getScheduleBox();
    await box.put(schedule.id, schedule.toMap());
    _schedules.add(schedule);
    notifyListeners();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final box = HiveService.getScheduleBox();
    await box.put(schedule.id, schedule.toMap());
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
    }
    notifyListeners();
  }

  Future<void> deleteSchedule(String id) async {
    final box = HiveService.getScheduleBox();
    await box.delete(id);
    _schedules.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // === GRADE METHODS ===
  void loadGrades() {
    final box = HiveService.getGradeBox();
    _grades = box.values
        .map((e) => Grade.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<void> addGrade(Grade grade) async {
    final box = HiveService.getGradeBox();
    await box.put(grade.id, grade.toMap());
    _grades.add(grade);
    notifyListeners();
  }

  Future<void> updateGrade(Grade grade) async {
    final box = HiveService.getGradeBox();
    await box.put(grade.id, grade.toMap());
    final index = _grades.indexWhere((g) => g.id == grade.id);
    if (index != -1) {
      _grades[index] = grade;
    }
    notifyListeners();
  }

  Future<void> deleteGrade(String id) async {
    final box = HiveService.getGradeBox();
    await box.delete(id);
    _grades.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // === ATTENDANCE METHODS ===
  void loadAttendances() {
    final box = HiveService.getAttendanceBox();
    _attendances = box.values
        .map((e) => Attendance.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<void> addAttendance(Attendance attendance) async {
    final box = HiveService.getAttendanceBox();
    await box.put(attendance.id, attendance.toMap());
    _attendances.add(attendance);
    notifyListeners();
  }

  Future<void> updateAttendance(Attendance attendance) async {
    final box = HiveService.getAttendanceBox();
    await box.put(attendance.id, attendance.toMap());
    final index = _attendances.indexWhere((a) => a.id == attendance.id);
    if (index != -1) {
      _attendances[index] = attendance;
    }
    notifyListeners();
  }

  Future<void> deleteAttendance(String id) async {
    final box = HiveService.getAttendanceBox();
    await box.delete(id);
    _attendances.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // === ASSIGNMENT METHODS ===
  void loadAssignments() {
    final box = HiveService.getAssignmentBox();
    _assignments = box.values
        .map((e) => Assignment.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<void> addAssignment(Assignment assignment) async {
    final box = HiveService.getAssignmentBox();
    await box.put(assignment.id, assignment.toMap());
    _assignments.add(assignment);
    notifyListeners();
  }

  Future<void> updateAssignment(Assignment assignment) async {
    final box = HiveService.getAssignmentBox();
    await box.put(assignment.id, assignment.toMap());
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = assignment;
    }
    notifyListeners();
  }

  Future<void> deleteAssignment(String id) async {
    final box = HiveService.getAssignmentBox();
    await box.delete(id);
    _assignments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // === ANNOUNCEMENT METHODS ===
  void loadAnnouncements() {
    final box = HiveService.getAnnouncementBox();
    _announcements = box.values
        .map((e) => Announcement.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    final box = HiveService.getAnnouncementBox();
    await box.put(announcement.id, announcement.toMap());
    _announcements.add(announcement);
    notifyListeners();
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    final box = HiveService.getAnnouncementBox();
    await box.put(announcement.id, announcement.toMap());
    final index = _announcements.indexWhere((a) => a.id == announcement.id);
    if (index != -1) {
      _announcements[index] = announcement;
    }
    notifyListeners();
  }

  Future<void> deleteAnnouncement(String id) async {
    final box = HiveService.getAnnouncementBox();
    await box.delete(id);
    _announcements.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // === PAYMENT METHODS ===
  void loadPayments() {
    final box = HiveService.getPaymentBox();
    _payments = box.values
        .map((e) => Payment.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<void> addPayment(Payment payment) async {
    final box = HiveService.getPaymentBox();
    await box.put(payment.id, payment.toMap());
    _payments.add(payment);
    notifyListeners();
  }

  Future<void> updatePayment(Payment payment) async {
    final box = HiveService.getPaymentBox();
    await box.put(payment.id, payment.toMap());
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _payments[index] = payment;
    }
    notifyListeners();
  }

  Future<void> deletePayment(String id) async {
    final box = HiveService.getPaymentBox();
    await box.delete(id);
    _payments.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // === MATERIAL METHODS ===
  void loadMaterials() {
    try {
      final box = HiveService.getMaterialBox();
      _materials = box.values
          .map(
            (e) =>
                material_model.Material.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading materials: $e');
      _materials = [];
      notifyListeners();
    }
  }

  Future<void> addMaterial(material_model.Material material) async {
    try {
      final box = HiveService.getMaterialBox();
      await box.put(material.id, material.toMap());
      _materials.add(material);
      notifyListeners();
    } catch (e) {
      print('Error adding material: $e');
      throw e;
    }
  }

  Future<void> updateMaterial(material_model.Material material) async {
    try {
      final box = HiveService.getMaterialBox();
      await box.put(material.id, material.toMap());
      final index = _materials.indexWhere((m) => m.id == material.id);
      if (index != -1) {
        _materials[index] = material;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating material: $e');
      throw e;
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      final box = HiveService.getMaterialBox();
      await box.delete(id);
      _materials.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting material: $e');
      throw e;
    }
  }

  // === UTILITY METHODS ===
  void clearAllData() {
    _schedules.clear();
    _grades.clear();
    _attendances.clear();
    _assignments.clear();
    _announcements.clear();
    _payments.clear();
    _calendarEvents.clear();
    _materials.clear();
    notifyListeners();
  }

  // Get events for specific date
  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _calendarEvents
        .where(
          (event) =>
              event.startDate.year == date.year &&
              event.startDate.month == date.month &&
              event.startDate.day == date.day,
        )
        .toList();
  }

  // Get upcoming events (next 7 days)
  List<CalendarEvent> getUpcomingEvents() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return _calendarEvents
        .where(
          (event) =>
              event.startDate.isAfter(now) &&
              event.startDate.isBefore(nextWeek),
        )
        .toList();
  }

  Future<void> addBulkAttendances(
    List<AttendanceEntity> newAttendances,
  ) async {}
}
