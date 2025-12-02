import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/calendar_event.dart';
import '../../../data/model/academic_year.dart';

class AcademicCalendarView extends StatelessWidget {
  const AcademicCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        // Get academic years from DataProvider, sorted by most recent first
        final academicYears =
            dataProvider.academicYears
                .where(
                  (year) => year.isActive,
                ) // Only show active academic years
                .toList()
              ..sort(
                (a, b) => b.startDate.compareTo(a.startDate),
              ); // Sort by start date descending

        return Container(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kalender Akademik',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
              ),
              Expanded(
                child: academicYears.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada tahun akademik\nyang tersedia',
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: academicYears.length,
                        itemBuilder: (context, index) {
                          final academicYear = academicYears[index];
                          final eventCount = dataProvider.calendarEvents
                              .where(
                                (event) =>
                                    _isEventInAcademicYear(event, academicYear),
                              )
                              .length;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => context.go(
                                '/student-dashboard/calendar/${academicYear.year}',
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: Colors.purple.shade700,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            academicYear.displayName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            academicYear.description.isNotEmpty
                                                ? academicYear.description
                                                : 'Juli ${academicYear.startDate.year} - Juni ${academicYear.endDate.year}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          if (eventCount > 0) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '$eventCount kegiatan',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.purple.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isEventInAcademicYear(CalendarEvent event, AcademicYear academicYear) {
    final eventYear = event.startDate.year;
    final eventMonth = event.startDate.month;
    final startYear = academicYear.startYear;
    final endYear = academicYear.endYear;

    if (eventYear == startYear && eventMonth >= 7) return true;
    if (eventYear == endYear && eventMonth <= 6) return true;
    return false;
  }
}
