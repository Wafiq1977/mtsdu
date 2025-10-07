import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/schedule.dart';
import '../models/grade.dart';
import '../models/attendance.dart';
import '../models/assignment.dart';
import '../models/announcement.dart';
import '../models/payment.dart';

import '../services/hive_service.dart';

class DataProvider with ChangeNotifier {
  List<Schedule> _schedules = [];
  List<Grade> _grades = [];
  List<Attendance> _attendances = [];
  List<Assignment> _assignments = [];
  List<Announcement> _announcements = [];
  List<Payment> _payments = [];
  List<Schedule> get schedules => _schedules;
  List<Grade> get grades => _grades;
  List<Attendance> get attendances => _attendances;
  List<Assignment> get assignments => _assignments;
  List<Announcement> get announcements => _announcements;
  List<Payment> get payments => _payments;

  DataProvider() {
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await loadSchedules();
    await loadGrades();
    await loadAttendances();
    await loadAssignments();
    await loadAnnouncements();
    await loadPayments();
  }

  Future<void> loadSchedules() async {
    final box = HiveService.getScheduleBox();
    _schedules = box.values.map((e) => Schedule.fromMap(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }

  Future<void> loadGrades() async {
    final box = HiveService.getGradeBox();
    _grades = box.values.map((e) => Grade.fromMap(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }

  Future<void> loadAttendances() async {
    final box = HiveService.getAttendanceBox();
    _attendances = box.values.map((e) => Attendance.fromMap(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }

  Future<void> loadAssignments() async {
    final box = HiveService.getAssignmentBox();
    _assignments = box.values.map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }

  Future<void> loadAnnouncements() async {
    final box = HiveService.getAnnouncementBox();
    _announcements = box.values.map((e) => Announcement.fromMap(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }

  Future<void> loadPayments() async {
    final box = HiveService.getPaymentBox();
    _payments = box.values.map((e) => Payment.fromMap(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }

  Future<void> addAssignment(Assignment assignment) async {
    final box = HiveService.getAssignmentBox();
    await box.put(assignment.id, assignment.toMap());
    _assignments.add(assignment);
    notifyListeners();
  }

  Future<void> addGrade(Grade grade) async {
    final box = HiveService.getGradeBox();
    await box.put(grade.id, grade.toMap());
    _grades.add(grade);
    notifyListeners();
  }

  Future<void> addAttendance(Attendance attendance) async {
    final box = HiveService.getAttendanceBox();
    await box.put(attendance.id, attendance.toMap());
    _attendances.add(attendance);
    notifyListeners();
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    final box = HiveService.getAnnouncementBox();
    await box.put(announcement.id, announcement.toMap());
    _announcements.add(announcement);
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

  // Similarly, add methods for add/update/delete for other models as needed
}
