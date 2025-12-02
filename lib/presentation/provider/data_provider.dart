import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lpmmtsdu/domain/entity/attendance_entity.dart';
import '../../../data/model/schedule.dart';
import '../../../data/model/grade.dart';
import '../../../data/model/attendance.dart' as attendance_model;
import '../../../data/model/assignment.dart';
import '../../../data/model/announcement.dart';
import '../../../data/model/payment.dart';
import '../../../data/model/calendar_event.dart'; // IMPORT BARU
import '../../../data/model/calendar_event_history.dart'; // IMPORT BARU
import '../../../data/model/material.dart' as material_model; // IMPORT BARU
import '../../../data/model/academic_year.dart'; // IMPORT BARU
import '../../../domain/entity/schedule_entity.dart'; // IMPORT BARU
import '../../../data/source/hive_service.dart';

class DataProvider with ChangeNotifier {
  List<Schedule> _schedules = [];
  List<Grade> _grades = [];
  List<attendance_model.Attendance> _attendances = [];
  List<Assignment> _assignments = [];
  List<Announcement> _announcements = [];
  List<Payment> _payments = [];
  List<CalendarEvent> _calendarEvents = []; // TAMBAH INI
  List<material_model.Material> _materials = []; // TAMBAH INI
  List<AcademicYear> _academicYears = []; // TAMBAH INI

  // Getters
  List<Schedule> get schedules => _schedules;
  List<Grade> get grades => _grades;
  List<attendance_model.Attendance> get attendances => _attendances;
  List<Assignment> get assignments => _assignments;
  List<Announcement> get announcements => _announcements;
  List<Payment> get payments => _payments;
  List<CalendarEvent> get calendarEvents => _calendarEvents; // TAMBAH INI
  List<material_model.Material> get materials => _materials; // TAMBAH INI
  List<AcademicYear> get academicYears => _academicYears; // TAMBAH INI

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
    loadAcademicYears();
    _initializeDummySchedules();
    _initializeDummyMaterials();
    _initializeDummyCalendarEvents();
    _initializeDummyAcademicYears();
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

  Future<void> updateCalendarEvent(
    CalendarEvent event, {
    String? userId,
    String? description,
  }) async {
    try {
      // Create history entry if userId and description provided
      CalendarEvent? oldEvent;
      if (userId != null && description != null) {
        oldEvent = _calendarEvents.firstWhere((e) => e.id == event.id);
      }

      final box = HiveService.getCalendarEventBox();
      await box.put(event.id, event.toMap());
      final index = _calendarEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _calendarEvents[index] = event;
      }

      // Add history entry
      if (oldEvent != null && userId != null && description != null) {
        final historyEntry = CalendarEventHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: event.id,
          action: 'updated',
          userId: userId,
          timestamp: DateTime.now(),
          oldData: oldEvent.toMap(),
          newData: event.toMap(),
          description: description,
        );

        final updatedEvent = CalendarEvent(
          id: event.id,
          title: event.title,
          description: event.description,
          startDate: event.startDate,
          endDate: event.endDate,
          type: event.type,
          location: event.location,
          createdBy: event.createdBy,
          color: event.color,
          target: event.target,
          history: [...event.history, historyEntry],
        );

        await box.put(updatedEvent.id, updatedEvent.toMap());
        _calendarEvents[index] = updatedEvent;
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

  // === ACADEMIC YEARS METHODS ===
  void loadAcademicYears() {
    try {
      final box = HiveService.getAcademicYearBox();
      _academicYears = box.values
          .map((e) => AcademicYear.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading academic years: $e');
      _academicYears = [];
      notifyListeners();
    }
  }

  Future<void> addAcademicYear(AcademicYear academicYear) async {
    try {
      final box = HiveService.getAcademicYearBox();
      await box.put(academicYear.id, academicYear.toMap());
      _academicYears.add(academicYear);
      notifyListeners();
    } catch (e) {
      print('Error adding academic year: $e');
      throw e;
    }
  }

  Future<void> updateAcademicYear(AcademicYear academicYear) async {
    try {
      final box = HiveService.getAcademicYearBox();
      await box.put(academicYear.id, academicYear.toMap());
      final index = _academicYears.indexWhere((a) => a.id == academicYear.id);
      if (index != -1) {
        _academicYears[index] = academicYear;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating academic year: $e');
      throw e;
    }
  }

  Future<void> deleteAcademicYear(String id) async {
    try {
      final box = HiveService.getAcademicYearBox();
      await box.delete(id);
      _academicYears.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting academic year: $e');
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
        .map(
          (e) =>
              attendance_model.Attendance.fromMap(Map<String, dynamic>.from(e)),
        )
        .toList();
    notifyListeners();
  }

  Future<void> addAttendance(attendance_model.Attendance attendance) async {
    final box = HiveService.getAttendanceBox();
    await box.put(attendance.id, attendance.toMap());
    _attendances.add(attendance);
    notifyListeners();
  }

  Future<void> updateAttendance(attendance_model.Attendance attendance) async {
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

  void _initializeDummyMaterials() {
    if (_materials.isEmpty) {
      final dummyMaterials = [
        material_model.Material(
          id: 'mat1',
          title: 'Aljabar Linear Dasar',
          description: 'Materi pengantar aljabar linear untuk siswa kelas 10',
          subject: 'Matematika',
          type: 'PDF',
          url: 'https://example.com/aljabar.pdf',
          major: 'Rekayasa Perangkat Lunak',
          teacherId: 'teacher1',
          className: '10A',
          uploadDate: '2024-01-15',
        ),
        material_model.Material(
          id: 'mat2',
          title: 'Hukum Newton',
          description: 'Penjelasan lengkap tentang hukum-hukum Newton',
          subject: 'Fisika',
          type: 'Video',
          url: 'https://example.com/newton.mp4',
          major: 'Rekayasa Perangkat Lunak',
          teacherId: 'teacher2',
          className: '10A',
          uploadDate: '2024-01-20',
        ),
        material_model.Material(
          id: 'mat3',
          title: 'Tata Bahasa Indonesia',
          description: 'Panduan lengkap tata bahasa Indonesia',
          subject: 'Bahasa Indonesia',
          type: 'Document',
          url: 'https://example.com/tata-bahasa.doc',
          major: 'Rekayasa Perangkat Lunak',
          teacherId: 'teacher3',
          className: '10A',
          uploadDate: '2024-01-25',
        ),
        material_model.Material(
          id: 'mat4',
          title: 'Reaksi Kimia Organik',
          description: 'Materi tentang reaksi kimia dalam senyawa organik',
          subject: 'Kimia',
          type: 'PPT',
          url: 'https://example.com/organik.ppt',
          major: 'Rekayasa Perangkat Lunak',
          teacherId: 'teacher4',
          className: '10A',
          uploadDate: '2024-02-01',
        ),
        material_model.Material(
          id: 'mat5',
          title: 'Kalkulus Differensial',
          description: 'Pengantar kalkulus untuk siswa SMA',
          subject: 'Matematika',
          type: 'PDF',
          url: 'https://example.com/kalkulus.pdf',
          major: 'Rekayasa Perangkat Lunak',
          teacherId: 'teacher1',
          className: '10A',
          uploadDate: '2024-02-05',
        ),
      ];

      for (final material in dummyMaterials) {
        addMaterial(material);
      }
    }
  }

  void _initializeDummySchedules() {
    if (_schedules.isEmpty) {
      final dummySchedules = [
        Schedule(
          id: 'sch1',
          subject: 'Matematika',
          assignedToId: 'teacher1',
          className: '10A',
          day: 'Monday',
          time: '07:00 - 08:30',
          room: '101',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 'sch2',
          subject: 'Bahasa Indonesia',
          assignedToId: 'teacher2',
          className: '10A',
          day: 'Monday',
          time: '08:45 - 10:15',
          room: '102',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 'sch3',
          subject: 'Fisika',
          assignedToId: 'teacher3',
          className: '10A',
          day: 'Tuesday',
          time: '07:00 - 08:30',
          room: '201',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 'sch4',
          subject: 'Kimia',
          assignedToId: 'teacher4',
          className: '10A',
          day: 'Tuesday',
          time: '08:45 - 10:15',
          room: '202',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 'sch5',
          subject: 'Biologi',
          assignedToId: 'teacher5',
          className: '10A',
          day: 'Wednesday',
          time: '07:00 - 08:30',
          room: '301',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 'sch6',
          subject: 'Sejarah',
          assignedToId: 'teacher6',
          className: '10A',
          day: 'Wednesday',
          time: '08:45 - 10:15',
          room: '302',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 'sch7',
          subject: 'Bahasa Inggris',
          assignedToId: 'teacher7',
          className: '10A',
          day: 'Thursday',
          time: '07:00 - 08:30',
          room: '401',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 'sch8',
          subject: 'Seni Budaya',
          assignedToId: 'teacher8',
          className: '10A',
          day: 'Thursday',
          time: '08:45 - 10:15',
          room: '402',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 'sch9',
          subject: 'Penjasorkes',
          assignedToId: 'teacher9',
          className: '10A',
          day: 'Friday',
          time: '07:00 - 08:30',
          room: 'Lapangan',
          scheduleType: ScheduleType.teacher,
        ),
        Schedule(
          id: 'sch10',
          subject: 'Agama',
          assignedToId: 'teacher10',
          className: '10A',
          day: 'Friday',
          time: '08:45 - 10:15',
          room: '103',
          scheduleType: ScheduleType.teacher,
        ),
      ];

      for (final schedule in dummySchedules) {
        addSchedule(schedule);
      }
    }
  }

  void _initializeDummyCalendarEvents() {
    if (_calendarEvents.isEmpty) {
      final dummyEvents = [
        CalendarEvent(
          id: 'event1',
          title: 'Pembukaan Tahun Ajaran 2024-2025',
          description:
              'Upacara pembukaan tahun ajaran baru dengan kegiatan pengenalan kurikulum dan program sekolah.',
          startDate: DateTime(2024, 7, 15),
          endDate: DateTime(2024, 7, 15, 12, 0), // Default 3 jam
          type: EventType.academic,
          location: 'Aula Sekolah',
          createdBy: 'admin',
        ),
        CalendarEvent(
          id: 'event2',
          title: 'Ujian Tengah Semester',
          description:
              'Pelaksanaan ujian tengah semester untuk semua mata pelajaran.',
          startDate: DateTime(2024, 10, 15),
          endDate: DateTime(2024, 10, 25),
          type: EventType.exam,
          location: 'Ruang Kelas',
          createdBy: 'admin',
        ),
        CalendarEvent(
          id: 'event3',
          title: 'Libur Hari Raya Idul Fitri',
          description: 'Libur Hari Raya Idul Fitri 1445 H.',
          startDate: DateTime(2024, 4, 10),
          endDate: DateTime(2024, 4, 17),
          type: EventType.holiday,
          createdBy: 'admin',
        ),
        CalendarEvent(
          id: 'event4',
          title: 'Rapat Orang Tua Siswa',
          description:
              'Rapat koordinasi antara guru, siswa, dan orang tua siswa.',
          startDate: DateTime(2024, 11, 20),
          endDate: DateTime(2024, 11, 20, 16, 0), // Default 3 jam
          type: EventType.meeting,
          location: 'Aula Sekolah',
          createdBy: 'admin',
        ),
        CalendarEvent(
          id: 'event5',
          title: 'Workshop Pengembangan Diri',
          description:
              'Workshop tentang pengembangan karakter dan keterampilan siswa.',
          startDate: DateTime(2024, 12, 5),
          endDate: DateTime(2024, 12, 5, 15, 0), // Default 3 jam
          type: EventType.academic,
          location: 'Ruang Multimedia',
          createdBy: 'admin',
        ),
        CalendarEvent(
          id: 'event6',
          title: 'Ujian Akhir Semester',
          description: 'Pelaksanaan ujian akhir semester untuk semua kelas.',
          startDate: DateTime(2025, 1, 15),
          endDate: DateTime(2025, 1, 30),
          type: EventType.exam,
          location: 'Ruang Kelas',
          createdBy: 'admin',
        ),
        CalendarEvent(
          id: 'event7',
          title: 'Libur Hari Raya Natal',
          description: 'Libur Hari Raya Natal 2024.',
          startDate: DateTime(2024, 12, 25),
          endDate: DateTime(2024, 12, 26),
          type: EventType.holiday,
          createdBy: 'admin',
        ),
        CalendarEvent(
          id: 'event8',
          title: 'Pembagian Raport',
          description:
              'Pembagian raport akhir semester dan pengumuman hasil belajar.',
          startDate: DateTime(2025, 2, 10),
          endDate: DateTime(2025, 2, 10, 12, 0), // Default 3 jam
          type: EventType.academic,
          location: 'Ruang Kelas',
          createdBy: 'admin',
        ),
        CalendarEvent(
          id: 'event9',
          title: 'Kegiatan Ekstrakurikuler',
          description:
              'Kegiatan ekstrakurikuler mingguan untuk pengembangan bakat siswa.',
          startDate: DateTime(2024, 9, 15),
          endDate: DateTime(2024, 9, 15, 16, 0), // Default 3 jam
          type: EventType.academic,
          location: 'Lapangan Sekolah',
          createdBy: 'admin',
        ),
        CalendarEvent(
          id: 'event10',
          title: 'Pengingat Pembayaran SPP',
          description: 'Pengingat untuk pembayaran SPP bulan ini.',
          startDate: DateTime(2024, 8, 1),
          endDate: DateTime(2024, 8, 1, 9, 0), // Default 1 jam
          type: EventType.reminder,
          createdBy: 'admin',
        ),
      ];

      for (final event in dummyEvents) {
        addCalendarEvent(event);
      }
    }
  }

  void _initializeDummyAcademicYears() {
    if (_academicYears.isEmpty) {
      final dummyAcademicYears = [
        AcademicYear(
          id: 'ay2024-2025',
          year: '2024-2025',
          name: 'Tahun Akademik 2024-2025',
          startDate: DateTime(2024, 7, 1),
          endDate: DateTime(2025, 6, 30),
          description:
              'Tahun akademik 2024-2025 dengan fokus pada pengembangan kompetensi siswa di era digital.',
          createdBy: 'admin',
          createdAt: DateTime.now(),
          isActive: true,
        ),
        AcademicYear(
          id: 'ay2025-2026',
          year: '2025-2026',
          name: 'Tahun Akademik 2025-2026',
          startDate: DateTime(2025, 7, 1),
          endDate: DateTime(2026, 6, 30),
          description:
              'Tahun akademik 2025-2026 dengan program pengembangan karakter dan keterampilan abad ke-21.',
          createdBy: 'admin',
          createdAt: DateTime.now(),
        ),
        AcademicYear(
          id: 'ay2026-2027',
          year: '2026-2027',
          name: 'Tahun Akademik 2026-2027',
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2027, 6, 30),
          description:
              'Tahun akademik 2026-2027 dengan inovasi pembelajaran berbasis teknologi.',
          createdBy: 'admin',
          createdAt: DateTime.now(),
        ),
      ];

      for (final academicYear in dummyAcademicYears) {
        addAcademicYear(academicYear);
      }
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
    _academicYears.clear();
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

  Future<void> addBulkAttendances(List<AttendanceEntity> newAttendances) async {
    try {
      final box = HiveService.getAttendanceBox();
      for (final attendance in newAttendances) {
        final attendanceModel = attendance_model.Attendance(
          id: attendance.id,
          studentId: attendance.studentId,
          subject: attendance.subject,
          date: attendance.date,
          status: attendance.status,
          teacherId: attendance.teacherId,
        );
        await box.put(attendanceModel.id, attendanceModel.toMap());
        _attendances.add(attendanceModel);
      }
      notifyListeners();
    } catch (e) {
      print('Error adding bulk attendances: $e');
      throw e;
    }
  }
}
