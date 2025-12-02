import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/calendar_event.dart';
import 'admin_calendar_history.dart';

class AdminAcademicCalendar extends StatefulWidget {
  final String? academicYear;

  const AdminAcademicCalendar({super.key, this.academicYear});

  @override
  State<AdminAcademicCalendar> createState() => _AdminAcademicCalendarState();
}

class _AdminAcademicCalendarState extends State<AdminAcademicCalendar> {
  CalendarController _calendarController = CalendarController();
  List<CalendarEvent> _events = [];
  bool _isLoading = true;
  String _userRole = 'admin'; // Default to admin, will be updated

  @override
  void initState() {
    super.initState();
    _loadData();
    _calendarController = CalendarController();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // Get user role
    final user = authProvider.currentUser;
    if (user != null) {
      _userRole = user.role
          .toString()
          .split('.')
          .last; // Convert enum to string
    }

    // Load and filter events based on user role
    final allEvents = dataProvider.calendarEvents;
    final filteredEvents = _filterEventsByRole(allEvents);

    setState(() {
      _events = filteredEvents;
      _isLoading = false;
    });
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) => CalendarEventDialog(
        onSave: (event) async {
          final dataProvider = Provider.of<DataProvider>(
            context,
            listen: false,
          );
          await dataProvider.addCalendarEvent(event);
          _loadData();
        },
        allowedEventTypes: _getAllowedEventTypes(),
      ),
    );
  }

  void _editEvent(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => CalendarEventDialog(
        event: event,
        onSave: (updatedEvent) async {
          final dataProvider = Provider.of<DataProvider>(
            context,
            listen: false,
          );
          await dataProvider.updateCalendarEvent(updatedEvent);
          _loadData();
        },
        allowedEventTypes: _getAllowedEventTypes(),
      ),
    );
  }

  void _deleteEvent(CalendarEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await dataProvider.deleteCalendarEvent(event.id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    }
  }

  // Role-based permissions
  bool _canAddEvent() {
    return _userRole == 'admin' || _userRole == 'teacher';
  }

  bool _canEditEvent(CalendarEvent event) {
    if (_userRole == 'admin') return true;
    if (_userRole == 'teacher') {
      // Teachers can only edit events they created
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      return user != null && event.createdBy == user.id;
    }
    return false;
  }

  bool _canDeleteEvent(CalendarEvent event) {
    // Only admin can delete events
    return _userRole == 'admin';
  }

  List<EventType> _getAllowedEventTypes() {
    if (_userRole == 'admin') {
      return EventType.values;
    } else if (_userRole == 'teacher') {
      // Teachers can create academic, meeting, and reminder events
      return [EventType.academic, EventType.meeting, EventType.reminder];
    }
    return [];
  }

  List<CalendarEvent> _filterEventsByRole(List<CalendarEvent> events) {
    return events.where((event) {
      switch (event.target) {
        case EventTarget.all:
          return true; // Visible to all users
        case EventTarget.students:
          return _userRole == 'student' || _userRole == 'admin';
        case EventTarget.teachers:
          return _userRole == 'teacher' || _userRole == 'admin';
        case EventTarget.admin:
          return _userRole == 'admin';
      }
    }).toList();
  }

  void _exportCalendar() {
    // TODO: Implement PDF/Word export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  void _viewHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdminCalendarHistory()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
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
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // If academic year is specified, show detail view
    if (widget.academicYear != null) {
      return _buildAcademicYearDetailView(widget.academicYear!);
    }

    // Otherwise, show academic years list
    return _buildAcademicYearsList();
  }

  Widget _buildAcademicYearsList() {
    // Generate academic years from 2020 to current year + 2
    final currentYear = DateTime.now().year;
    final academicYears = List.generate(
      8,
      (index) => '${currentYear - 4 + index}-${currentYear - 3 + index}',
    ).reversed.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
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
                // Header Section with Back Button and Title
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Back Button Row
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/admin-dashboard'),
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Kembali',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              fixedSize: const Size(40, 40),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Kembali ke Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      const Text(
                        'Kalender Akademik',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Academic Years List
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: academicYears.length,
                          itemBuilder: (context, index) {
                            final year = academicYears[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _navigateToAcademicYear(year),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF667EEA,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF667EEA),
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
                                              year,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Juli ${year.split('-')[0]} - Juni ${year.split('-')[1]}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAcademicYearDetailView(String academicYear) {
    // Parse academic year
    final years = academicYear.split('-');
    final startYear = int.parse(years[0]);
    final endYear = int.parse(years[1]);

    // Filter events for this academic year (July startYear to June endYear)
    final academicEvents = _events.where((event) {
      final eventYear = event.startDate.year;
      final eventMonth = event.startDate.month;

      // Academic year: July (year) to June (year+1)
      if (eventYear == startYear && eventMonth >= 7) return true;
      if (eventYear == endYear && eventMonth <= 6) return true;

      return false;
    }).toList();

    // Sort by date
    academicEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
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
                // Header Section with Back Button and Title
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Back Button Row
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _navigateBackToYearsList(),
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Kembali',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              fixedSize: const Size(40, 40),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Kembali ke Daftar Tahun',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title and Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kalender $academicYear',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Kelola kegiatan akademik tahun ini',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isMobile && _canAddEvent()) ...[
                            const SizedBox(width: 16),
                            FilledButton.tonalIcon(
                              onPressed: () => _viewHistory(),
                              icon: const Icon(Icons.history),
                              label: const Text('Riwayat'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () => _addEventForYear(academicYear),
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Kegiatan'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667EEA),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Mobile Actions
                      if (isMobile) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () => _viewHistory(),
                                icon: const Icon(Icons.history),
                                label: const Text('Riwayat'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_canAddEvent()) ...[
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () =>
                                      _addEventForYear(academicYear),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tambah Kegiatan'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF667EEA),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Events List
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
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
                                    if (_canAddEvent()) ...[
                                      const SizedBox(height: 16),
                                      FilledButton.icon(
                                        onPressed: () =>
                                            _addEventForYear(academicYear),
                                        icon: const Icon(Icons.add),
                                        label: const Text(
                                          'Tambah Kegiatan Pertama',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: academicEvents.length,
                                itemBuilder: (context, index) {
                                  final event = academicEvents[index];
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
                                                        color: _getEventColor(
                                                          event.type,
                                                        ).withOpacity(0.1),
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
                                                          color: _getEventColor(
                                                            event.type,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (_canEditEvent(event)) ...[
                                                PopupMenuButton<String>(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                  ),
                                                  onSelected: (value) {
                                                    switch (value) {
                                                      case 'edit':
                                                        _editEvent(event);
                                                        break;
                                                      case 'delete':
                                                        _deleteEvent(event);
                                                        break;
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.edit,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text('Edit'),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.delete,
                                                            size: 18,
                                                            color: Colors.red,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
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
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToAcademicYear(String year) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: AcademicYearDetailDialog(
            academicYear: year,
            events: _getEventsForAcademicYear(year),
            onAddEvent: () => _addEventForYear(year),
            onEditEvent: _editEvent,
            onDeleteEvent: _deleteEvent,
            canEditEvent: _canEditEvent,
            canDeleteEvent: _canDeleteEvent,
          ),
        ),
      ),
    );
  }

  void _navigateBackToYearsList() {
    // Similar issue - need to communicate with parent
    // For now, we'll use setState to clear the academic year
    // But since this is a const widget, we need a different approach

    // Actually, since this widget is created fresh each time in admin dashboard,
    // we need to modify how it's instantiated.
  }

  List<CalendarEvent> _getEventsForAcademicYear(String academicYear) {
    // Parse academic year
    final years = academicYear.split('-');
    final startYear = int.parse(years[0]);
    final endYear = int.parse(years[1]);

    // Filter events for this academic year (July startYear to June endYear)
    return _events.where((event) {
      final eventYear = event.startDate.year;
      final eventMonth = event.startDate.month;

      // Academic year: July (year) to June (year+1)
      if (eventYear == startYear && eventMonth >= 7) return true;
      if (eventYear == endYear && eventMonth <= 6) return true;

      return false;
    }).toList();
  }

  void _addEventForYear(String academicYear) {
    // Parse the academic year to get start date
    final years = academicYear.split('-');
    final startYear = int.parse(years[0]);
    final startDate = DateTime(startYear, 7, 1); // July 1st of academic year

    showDialog(
      context: context,
      builder: (context) => AcademicEventDialog(
        academicYear: academicYear,
        onSave: (title, description) async {
          final dataProvider = Provider.of<DataProvider>(
            context,
            listen: false,
          );

          final event = CalendarEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            description: description,
            startDate: startDate,
            type: EventType.academic,
            createdBy: _userRole,
            target: EventTarget.all,
          );

          await dataProvider.addCalendarEvent(event);
          _loadData();
        },
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.academic:
        return Colors.blue;
      case EventType.holiday:
        return Colors.green;
      case EventType.exam:
        return Colors.red;
      case EventType.meeting:
        return Colors.orange;
      case EventType.reminder:
        return Colors.teal;
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

  void _showDateEvents(DateTime date) {
    final dayEvents = _events
        .where(
          (event) =>
              event.startDate.year == date.year &&
              event.startDate.month == date.month &&
              event.startDate.day == date.day,
        )
        .toList();

    showDialog(
      context: context,
      builder: (context) => DateEventsDialog(
        date: date,
        events: dayEvents,
        onAddEvent: _canAddEvent() ? _addEvent : null,
        onEditEvent: _editEvent,
        onDeleteEvent: _deleteEvent,
        canEditEvent: _canEditEvent,
        canDeleteEvent: _canDeleteEvent,
      ),
    );
  }
}

// Data Source untuk Calendar
class EventDataSource extends CalendarDataSource {
  EventDataSource(List<CalendarEvent> events) {
    this.appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startDate;
  }

  @override
  DateTime getEndTime(int index) {
    final event = appointments![index] as CalendarEvent;
    // Jika endDate null, gunakan startDate + 1 jam sebagai default
    return event.endDate ?? event.startDate.add(const Duration(hours: 1));
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }
}

// Dialog untuk Add/Edit Event
class CalendarEventDialog extends StatefulWidget {
  final Function(CalendarEvent) onSave;
  final CalendarEvent? event;
  final List<EventType>? allowedEventTypes;

  const CalendarEventDialog({
    super.key,
    required this.onSave,
    this.event,
    this.allowedEventTypes,
  });

  @override
  State<CalendarEventDialog> createState() => _CalendarEventDialogState();
}

class _CalendarEventDialogState extends State<CalendarEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  Color _selectedColor = Colors.blue;
  EventType _selectedType = EventType.academic;
  EventTarget _selectedTarget = EventTarget.all;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _startDate = widget.event!.startDate;
      _endDate =
          widget.event!.endDate ?? DateTime.now().add(const Duration(hours: 1));
      _selectedColor = widget.event!.color;
      _selectedType = widget.event!.type;
      _selectedTarget = widget.event!.target;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Date & Time'),
                        FilledButton.tonal(
                          onPressed: () => _selectDateTime(true),
                          child: Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startDate.hour}:${_startDate.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End Date & Time'),
                        FilledButton.tonal(
                          onPressed: () => _selectDateTime(false),
                          child: Text(
                            '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endDate.hour}:${_endDate.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EventType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                items: (widget.allowedEventTypes ?? EventType.values).map((
                  type,
                ) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getEventIcon(type), color: _getEventColor(type)),
                        const SizedBox(width: 8),
                        Text(_getEventLabel(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    _selectedColor = _getEventColor(value);
                  });
                },
              ),
              const SizedBox(height: 12),
              const Text('Color'),
              Wrap(
                spacing: 8,
                children: [
                  _buildColorOption(Colors.blue),
                  _buildColorOption(Colors.green),
                  _buildColorOption(Colors.orange),
                  _buildColorOption(Colors.purple),
                  _buildColorOption(Colors.red),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EventTarget>(
                value: _selectedTarget,
                decoration: const InputDecoration(
                  labelText: 'Target Audience',
                  border: OutlineInputBorder(),
                ),
                items: EventTarget.values.map((target) {
                  return DropdownMenuItem(
                    value: target,
                    child: Text(_getTargetLabel(target)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTarget = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _saveEvent, child: const Text('Save')),
      ],
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _selectedColor == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }

  Future<void> _selectDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
      );

      if (time != null) {
        setState(() {
          final newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStart) {
            _startDate = newDateTime;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 1));
            }
          } else {
            _endDate = newDateTime;
          }
        });
      }
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      // Get current user for createdBy
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser!;

      final event = CalendarEvent(
        id:
            widget.event?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        color: _selectedColor,
        type: _selectedType,
        location: '',
        createdBy: user.id,
        target: _selectedTarget,
      );

      widget.onSave(event);
      Navigator.of(context).pop();
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.academic:
        return Icons.school;
      case EventType.holiday:
        return Icons.beach_access;
      case EventType.exam:
        return Icons.assignment;
      case EventType.meeting:
        return Icons.people;
      case EventType.reminder:
        return Icons.notifications;
    }
  }

  String _getEventLabel(EventType type) {
    switch (type) {
      case EventType.academic:
        return 'Academic';
      case EventType.holiday:
        return 'Holiday';
      case EventType.exam:
        return 'Exam';
      case EventType.meeting:
        return 'Meeting';
      case EventType.reminder:
        return 'Reminder';
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.academic:
        return Colors.blue;
      case EventType.holiday:
        return Colors.green;
      case EventType.exam:
        return Colors.orange;
      case EventType.meeting:
        return Colors.purple;
      case EventType.reminder:
        return Colors.red;
    }
  }

  String _getTargetLabel(EventTarget target) {
    switch (target) {
      case EventTarget.all:
        return 'All Users';
      case EventTarget.students:
        return 'Students Only';
      case EventTarget.teachers:
        return 'Teachers Only';
      case EventTarget.admin:
        return 'Admin Only';
    }
  }
}

// Dialog untuk melihat events di tanggal tertentu
class DateEventsDialog extends StatelessWidget {
  final DateTime date;
  final List<CalendarEvent> events;
  final VoidCallback? onAddEvent;
  final Function(CalendarEvent)? onEditEvent;
  final Function(CalendarEvent)? onDeleteEvent;
  final bool Function(CalendarEvent)? canEditEvent;
  final bool Function(CalendarEvent)? canDeleteEvent;

  const DateEventsDialog({
    super.key,
    required this.date,
    required this.events,
    this.onAddEvent,
    this.onEditEvent,
    this.onDeleteEvent,
    this.canEditEvent,
    this.canDeleteEvent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('Events on ${_formatDate(date)}'),
          const Spacer(),
          if (onAddEvent != null)
            IconButton(
              onPressed: onAddEvent,
              icon: const Icon(Icons.add),
              tooltip: 'Add Event',
            ),
        ],
      ),
      content: events.isEmpty
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('No events scheduled'),
              ],
            )
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: event.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      title: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.description),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${_formatTime(event.startDate)} - ${_formatTime(event.endDate ?? event.startDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (event.target != EventTarget.all) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTargetColor(event.target),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getTargetShortLabel(event.target),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              if (onEditEvent != null) {
                                Navigator.of(
                                  context,
                                ).pop(); // Close current dialog
                                onEditEvent!(event);
                              }
                              break;
                            case 'delete':
                              if (onDeleteEvent != null) {
                                _showDeleteConfirmation(context, event);
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) {
                          final List<PopupMenuEntry<String>> items = [];

                          // Add Edit option if user can edit this event
                          if (canEditEvent != null && canEditEvent!(event)) {
                            items.add(
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Add Delete option if user can delete this event
                          if (canDeleteEvent != null &&
                              canDeleteEvent!(event)) {
                            items.add(
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return items;
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (onDeleteEvent != null) {
                onDeleteEvent!(event);
              }
              Navigator.of(context).pop(); // Close confirmation
              Navigator.of(context).pop(); // Close events dialog
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getTargetColor(EventTarget target) {
    switch (target) {
      case EventTarget.all:
        return Colors.grey;
      case EventTarget.students:
        return Colors.blue;
      case EventTarget.teachers:
        return Colors.green;
      case EventTarget.admin:
        return Colors.red;
    }
  }

  String _getTargetShortLabel(EventTarget target) {
    switch (target) {
      case EventTarget.all:
        return 'ALL';
      case EventTarget.students:
        return 'STUDENTS';
      case EventTarget.teachers:
        return 'TEACHERS';
      case EventTarget.admin:
        return 'ADMIN';
    }
  }
}

// Simplified dialog for academic events (only title and description)
class AcademicEventDialog extends StatefulWidget {
  final String academicYear;
  final Function(String title, String description) onSave;

  const AcademicEventDialog({
    super.key,
    required this.academicYear,
    required this.onSave,
  });

  @override
  State<AcademicEventDialog> createState() => _AcademicEventDialogState();
}

class _AcademicEventDialogState extends State<AcademicEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Kegiatan - ${widget.academicYear}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Kegiatan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Kegiatan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _saveEvent, child: const Text('Simpan')),
      ],
    );
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_titleController.text, _descriptionController.text);
      Navigator.of(context).pop();
    }
  }
}

// Dialog for academic year detail view
class AcademicYearDetailDialog extends StatelessWidget {
  final String academicYear;
  final List<CalendarEvent> events;
  final VoidCallback onAddEvent;
  final Function(CalendarEvent) onEditEvent;
  final Function(CalendarEvent) onDeleteEvent;
  final bool Function(CalendarEvent) canEditEvent;
  final bool Function(CalendarEvent) canDeleteEvent;

  const AcademicYearDetailDialog({
    super.key,
    required this.academicYear,
    required this.events,
    required this.onAddEvent,
    required this.onEditEvent,
    required this.onDeleteEvent,
    required this.canEditEvent,
    required this.canDeleteEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender $academicYear'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAddEvent,
            tooltip: 'Tambah Kegiatan',
          ),
        ],
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
                    child: events.isEmpty
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
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: onAddEvent,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tambah Kegiatan Pertama'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
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
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
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
                                                    color: _getEventColor(
                                                      event.type,
                                                    ).withOpacity(0.1),
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
                                                      color: _getEventColor(
                                                        event.type,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (canEditEvent(event)) ...[
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert),
                                              onSelected: (value) {
                                                switch (value) {
                                                  case 'edit':
                                                    onEditEvent(event);
                                                    break;
                                                  case 'delete':
                                                    onDeleteEvent(event);
                                                    break;
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Edit'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
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
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.academic:
        return Colors.blue;
      case EventType.holiday:
        return Colors.green;
      case EventType.exam:
        return Colors.red;
      case EventType.meeting:
        return Colors.orange;
      case EventType.reminder:
        return Colors.teal;
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
}
