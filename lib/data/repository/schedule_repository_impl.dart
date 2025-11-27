import '../../domain/repository/schedule_repository.dart';
import '../../domain/entity/schedule_entity.dart';
import '../model/schedule.dart' as model;
import '../source/hive_service.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    final box = HiveService.getScheduleBox();
    return box.values.map((e) => _mapModelToEntity(model.Schedule.fromMap(Map<String, dynamic>.from(e)))).toList();
  }

  @override
  Future<ScheduleEntity?> getScheduleById(String id) async {
    final box = HiveService.getScheduleBox();
    final scheduleMap = box.get(id);
    if (scheduleMap != null) {
      return _mapModelToEntity(model.Schedule.fromMap(Map<String, dynamic>.from(scheduleMap)));
    }
    return null;
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByTeacher(String teacherId) async {
    final schedules = await getAllSchedules();
    return schedules.where((schedule) => schedule.assignedToId == teacherId).toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByClass(String className) async {
    final schedules = await getAllSchedules();
    return schedules.where((schedule) => schedule.className == className).toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByDay(String day) async {
    final schedules = await getAllSchedules();
    return schedules.where((schedule) => schedule.day == day).toList();
  }

  @override
  Future<void> addSchedule(ScheduleEntity schedule) async {
    final box = HiveService.getScheduleBox();
    await box.put(schedule.id, _mapEntityToModel(schedule).toMap());
  }

  @override
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    final box = HiveService.getScheduleBox();
    await box.put(schedule.id, _mapEntityToModel(schedule).toMap());
  }

  @override
  Future<void> deleteSchedule(String id) async {
    final box = HiveService.getScheduleBox();
    await box.delete(id);
  }

  ScheduleEntity _mapModelToEntity(model.Schedule schedule) {
    return ScheduleEntity(
      id: schedule.id,
      subject: schedule.subject,
      assignedToId: schedule.assignedToId,
      className: schedule.className,
      day: schedule.day,
      time: schedule.time,
      room: schedule.room,
      scheduleType: schedule.scheduleType,
      major: schedule.major,
      grade: schedule.grade,
    );
  }

  model.Schedule _mapEntityToModel(ScheduleEntity schedule) {
    return model.Schedule(
      id: schedule.id,
      subject: schedule.subject,
      assignedToId: schedule.assignedToId,
      className: schedule.className,
      day: schedule.day,
      time: schedule.time,
      room: schedule.room,
      scheduleType: schedule.scheduleType,
      major: schedule.major,
      grade: schedule.grade,
    );
  }
}
