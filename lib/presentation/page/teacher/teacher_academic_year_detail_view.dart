import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/calendar_event.dart';

class TeacherAcademicYearDetailView extends StatelessWidget {
  final String academicYear;

  const TeacherAcademicYearDetailView({super.key, required this.academicYear});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getDayName(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[date.weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.academic:
        return Colors.purple; // Changed from blue to purple for consistency
      case EventType.holiday:
        return Colors.green;
      case EventType.exam:
        return Colors.red;
      case EventType.meeting:
        return Colors.orange;
      case EventType.reminder:
        return Colors.teal; // Changed from purple to teal to avoid conflict
    }
  }

  String _getEventTypeName(EventType type) {
    switch (type) {
      case EventType.academic:
        return 'Akademik';
      case EventType.holiday:
        return 'Libur';
      case EventType.exam:
        return 'Ujian';
      case EventType.meeting:
        return 'Rapat';
      case EventType.reminder:
        return 'Pengingat';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        // Parse academic year
        final years = academicYear.split('-');
        final startYear = int.parse(years[0]);
        final endYear = int.parse(years[1]);

        // Filter events for this academic year (July startYear to June endYear)
        final academicEvents = dataProvider.calendarEvents.where((event) {
          final eventYear = event.startDate.year;
          final eventMonth = event.startDate.month;

          // Academic year: July (year) to June (year+1)
          if (eventYear == startYear && eventMonth >= 7) return true;
          if (eventYear == endYear && eventMonth <= 6) return true;

          return false;
        }).toList();

        // Sort by date
        academicEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/teacher-dashboard/kalender');
                }
              },
            ),
            title: Text('Kalender $academicYear'),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                  Color(0xFFF093FB),
                  Color(0xFFF5576C),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      academicYear,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: academicEvents.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_note,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada kegiatan\nuntuk tahun akademik ini',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: academicEvents.length,
                                itemBuilder: (context, index) {
                                  final event = academicEvents[index];
                                  final eventColor = _getEventColor(event.type);

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: eventColor.withOpacity(
                                                    0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.event,
                                                  color: eventColor,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      event.title,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: eventColor
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        _getEventTypeName(
                                                          event.type,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: eventColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.calendar_today,
                                                      size: 16,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _formatDate(
                                                        event.startDate,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 16,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _getDayName(
                                                        event.startDate,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.date_range,
                                                      size: 16,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _getMonthName(
                                                        event.startDate.month,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Text(
                                                      event.startDate.year
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (event.description.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              event.description,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                          if (event.location != null &&
                                              event.location!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  event.location!,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
