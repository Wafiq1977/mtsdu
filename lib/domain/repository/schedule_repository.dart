import '../entity/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> getAllSchedules();
  Future<ScheduleEntity?> getScheduleById(String id);
  Future<List<ScheduleEntity>> getSchedulesByTeacher(String teacherId);
  Future<List<ScheduleEntity>> getSchedulesByClass(String className);
  Future<List<ScheduleEntity>> getSchedulesByDay(String day);
  Future<void> addSchedule(ScheduleEntity schedule);
  Future<void> updateSchedule(ScheduleEntity schedule);
  Future<void> deleteSchedule(String id);
}
