import '../model/schedule.dart';
import '../source/hive_service.dart';

class ScheduleService {
  Future<List<Schedule>> getAllSchedules() async {
    final box = HiveService.getScheduleBox();
    return box.values.map((e) => Schedule.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<Schedule?> getScheduleById(String id) async {
    final box = HiveService.getScheduleBox();
    final scheduleMap = box.get(id);
    if (scheduleMap != null) {
      return Schedule.fromMap(Map<String, dynamic>.from(scheduleMap));
    }
    return null;
  }

  Future<List<Schedule>> getSchedulesByTeacher(String teacherId) async {
    final box = HiveService.getScheduleBox();
    final schedules = box.values.map((e) => Schedule.fromMap(Map<String, dynamic>.from(e))).toList();
    return schedules.where((schedule) => schedule.assignedToId == teacherId).toList();
  }

  Future<List<Schedule>> getSchedulesByClass(String className) async {
    final box = HiveService.getScheduleBox();
    final schedules = box.values.map((e) => Schedule.fromMap(Map<String, dynamic>.from(e))).toList();
    return schedules.where((schedule) => schedule.className == className).toList();
  }

  Future<List<Schedule>> getSchedulesByDay(String day) async {
    final box = HiveService.getScheduleBox();
    final schedules = box.values.map((e) => Schedule.fromMap(Map<String, dynamic>.from(e))).toList();
    return schedules.where((schedule) => schedule.day == day).toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    final box = HiveService.getScheduleBox();
    await box.put(schedule.id, schedule.toMap());
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final box = HiveService.getScheduleBox();
    await box.put(schedule.id, schedule.toMap());
  }

  Future<void> deleteSchedule(String id) async {
    final box = HiveService.getScheduleBox();
    await box.delete(id);
  }
}
