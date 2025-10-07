import '../models/announcement.dart';
import 'hive_service.dart';

class AnnouncementService {
  Future<List<Announcement>> getAllAnnouncements() async {
    final box = HiveService.getAnnouncementBox();
    return box.values.map((e) => Announcement.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<Announcement?> getAnnouncementById(String id) async {
    final box = HiveService.getAnnouncementBox();
    final announcementMap = box.get(id);
    if (announcementMap != null) {
      return Announcement.fromMap(Map<String, dynamic>.from(announcementMap));
    }
    return null;
  }

  Future<List<Announcement>> getAnnouncementsByAuthor(String authorId) async {
    final box = HiveService.getAnnouncementBox();
    final announcements = box.values.map((e) => Announcement.fromMap(Map<String, dynamic>.from(e))).toList();
    return announcements.where((announcement) => announcement.authorId == authorId).toList();
  }

  Future<List<Announcement>> getAnnouncementsByTargetRole(String targetRole) async {
    final box = HiveService.getAnnouncementBox();
    final announcements = box.values.map((e) => Announcement.fromMap(Map<String, dynamic>.from(e))).toList();
    return announcements.where((announcement) => announcement.targetRole == targetRole || announcement.targetRole == 'all').toList();
  }

  Future<List<Announcement>> getRecentAnnouncements({int limit = 10}) async {
    final box = HiveService.getAnnouncementBox();
    final announcements = box.values.map((e) => Announcement.fromMap(Map<String, dynamic>.from(e))).toList();
    announcements.sort((a, b) => b.date.compareTo(a.date));
    return announcements.take(limit).toList();
  }

  Future<List<Announcement>> getAnnouncementsByDateRange(String startDate, String endDate) async {
    final box = HiveService.getAnnouncementBox();
    final announcements = box.values.map((e) => Announcement.fromMap(Map<String, dynamic>.from(e))).toList();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);

    return announcements.where((announcement) {
      final announcementDate = announcement.date;
      return announcementDate.isAfter(start.subtract(const Duration(days: 1))) &&
             announcementDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    final box = HiveService.getAnnouncementBox();
    await box.put(announcement.id, announcement.toMap());
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    final box = HiveService.getAnnouncementBox();
    await box.put(announcement.id, announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    final box = HiveService.getAnnouncementBox();
    await box.delete(id);
  }
}
