import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../data/model/calendar_event.dart';

class AdminAcademicCalendar extends StatefulWidget {
  const AdminAcademicCalendar({super.key});

  @override
  State<AdminAcademicCalendar> createState() => _AdminAcademicCalendarState();
}

class _AdminAcademicCalendarState extends State<AdminAcademicCalendar> {
  CalendarController _calendarController = CalendarController();
  List<CalendarEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _calendarController = CalendarController();
  }

  Future<void> _loadEvents() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final events = dataProvider.calendarEvents;
    
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) => CalendarEventDialog(
        onSave: (event) async {
          final dataProvider = Provider.of<DataProvider>(context, listen: false);
          await dataProvider.addCalendarEvent(event);
          _loadEvents();
        },
      ),
    );
  }

  void _exportCalendar() {
    // TODO: Implement PDF/Word export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header dengan Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Academic Calendar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _addEvent,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Event'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: _exportCalendar,
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Calendar View
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: SfCalendar(
              controller: _calendarController,
              view: CalendarView.month,
              dataSource: EventDataSource(_events),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell) {
                  _showDateEvents(details.date!);
                }
              },
              monthViewSettings: const MonthViewSettings(
                showAgenda: true,
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDateEvents(DateTime date) {
    final dayEvents = _events.where((event) => 
      event.startDate.year == date.year &&
      event.startDate.month == date.month &&
      event.startDate.day == date.day
    ).toList();

    showDialog(
      context: context,
      builder: (context) => DateEventsDialog(
        date: date,
        events: dayEvents,
        onAddEvent: _addEvent,
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
    return appointments![index].endDate;
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

  const CalendarEventDialog({super.key, required this.onSave, this.event});

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

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _startDate = widget.event!.startDate;
      _endDate = widget.event!.endDate ?? DateTime.now().add(const Duration(hours: 1));
      _selectedColor = widget.event!.color;
      _selectedType = widget.event!.type;
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
                items: EventType.values.map((type) {
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveEvent,
          child: const Text('Save'),
        ),
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
            date.year, date.month, date.day, time.hour, time.minute,
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
        id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        color: _selectedColor,
        type: _selectedType,
        location: '',
        createdBy: user.id,
      );

      widget.onSave(event);
      Navigator.of(context).pop();
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.academic: return Icons.school;
      case EventType.holiday: return Icons.beach_access;
      case EventType.exam: return Icons.assignment;
      case EventType.meeting: return Icons.people;
      case EventType.reminder: return Icons.notifications;
    }
  }

  String _getEventLabel(EventType type) {
    switch (type) {
      case EventType.academic: return 'Academic';
      case EventType.holiday: return 'Holiday';
      case EventType.exam: return 'Exam';
      case EventType.meeting: return 'Meeting';
      case EventType.reminder: return 'Reminder';
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.academic: return Colors.blue;
      case EventType.holiday: return Colors.green;
      case EventType.exam: return Colors.orange;
      case EventType.meeting: return Colors.purple;
      case EventType.reminder: return Colors.red;
    }
  }
}

// Dialog untuk melihat events di tanggal tertentu
class DateEventsDialog extends StatelessWidget {
  final DateTime date;
  final List<CalendarEvent> events;
  final VoidCallback onAddEvent;

  const DateEventsDialog({
    super.key,
    required this.date,
    required this.events,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('Events on ${_formatDate(date)}'),
          const Spacer(),
          IconButton(
            onPressed: onAddEvent,
            icon: const Icon(Icons.add),
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
                      title: Text(event.title),
                      subtitle: Text(event.description),
                      trailing: Text(
                        '${event.startDate.hour}:${event.startDate.minute.toString().padLeft(2, '0')}',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
