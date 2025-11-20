import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/schedule.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

class AdminScheduleManagement extends StatefulWidget {
  const AdminScheduleManagement({super.key});

  @override
  State<AdminScheduleManagement> createState() => _AdminScheduleManagementState();
}

class _AdminScheduleManagementState extends State<AdminScheduleManagement> {
  List<Schedule> _schedules = [];
  List<User> _teachers = [];
  List<User> _students = [];
  bool _isLoading = true;
  String? _selectedDay;
  bool _showTools = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final schedules = dataProvider.schedules;
    final allUsers = await authProvider.getAllUsers();
    final teachers = allUsers.where((u) => u.role == UserRole.teacher).toList();
    final students = allUsers.where((u) => u.role == UserRole.student).toList();

    setState(() {
      _schedules = schedules;
      _teachers = teachers;
      _students = students;
      _isLoading = false;
    });
  }

  void _addSchedule() {
    _showScheduleDialog();
  }

  void _editSchedule(Schedule schedule) {
    _showScheduleDialog(schedule: schedule);
  }

  void _deleteSchedule(Schedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete schedule for ${schedule.subject}?'),
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
      await dataProvider.deleteSchedule(schedule.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule deleted')),
      );
    }
  }

  void _showScheduleDialog({Schedule? schedule}) {
    final isEditing = schedule != null;
    final formKey = GlobalKey<FormState>();
    String subject = schedule?.subject ?? '';
    String assignedToId = schedule?.assignedToId ?? '';
    String className = schedule?.className ?? '';
    String day = schedule?.day ?? 'Monday';
    String time = schedule?.time ?? '';
    String room = schedule?.room ?? '';
    ScheduleType scheduleType = schedule?.scheduleType ?? ScheduleType.teacher;

    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Schedule' : 'Add Schedule'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: subject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => subject = value!,
                ),
                DropdownButtonFormField<ScheduleType>(
                  value: scheduleType,
                  decoration: const InputDecoration(labelText: 'Schedule Type'),
                  items: [
                    DropdownMenuItem(
                      value: ScheduleType.teacher,
                      child: Text('Teacher Schedule'),
                    ),
                    DropdownMenuItem(
                      value: ScheduleType.student,
                      child: Text('Student Schedule'),
                    ),
                  ],
                  onChanged: (value) => setState(() => scheduleType = value!),
                ),
                if (scheduleType == ScheduleType.teacher)
                  DropdownButtonFormField<String>(
                    value: assignedToId.isNotEmpty ? assignedToId : null,
                    decoration: const InputDecoration(labelText: 'Teacher'),
                    items: _teachers.map((teacher) => DropdownMenuItem(
                      value: teacher.id,
                      child: Text(teacher.name),
                    )).toList(),
                    onChanged: (value) => assignedToId = value!,
                    onSaved: (value) => assignedToId = value!,
                    validator: (value) => value == null ? 'Required' : null,
                  )
                else
                  DropdownButtonFormField<String>(
                    value: assignedToId.isNotEmpty ? assignedToId : null,
                    decoration: const InputDecoration(labelText: 'Student'),
                    items: _students.map((student) => DropdownMenuItem(
                      value: student.id,
                      child: Text(student.name),
                    )).toList(),
                    onChanged: (value) => assignedToId = value!,
                    onSaved: (value) => assignedToId = value!,
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                DropdownButtonFormField<String>(
                  value: className.isNotEmpty ? className : null,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: _students.map((student) => DropdownMenuItem(
                    value: student.className,
                    child: Text(student.className ?? ''),
                  )).toSet().toList(),
                  onChanged: (value) => className = value ?? '',
                  onSaved: (value) => className = value ?? '',
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: day,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: daysOfWeek.map((day) => DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  )).toList(),
                  onChanged: (value) => day = value!,
                ),
                TextFormField(
                  initialValue: time,
                  decoration: const InputDecoration(labelText: 'Time (e.g., 08:00-09:00)'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => time = value!,
                ),
                TextFormField(
                  initialValue: room,
                  decoration: const InputDecoration(labelText: 'Room'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => room = value!,
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
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final dataProvider = Provider.of<DataProvider>(context, listen: false);

                final newSchedule = Schedule(
                  id: isEditing ? schedule!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  subject: subject,
                  assignedToId: assignedToId,
                  className: className,
                  day: day,
                  time: time,
                  room: room,
                  scheduleType: scheduleType,
                );

                if (isEditing) {
                  await dataProvider.updateSchedule(newSchedule);
                } else {
                  await dataProvider.addSchedule(newSchedule);
                }
                _loadData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${isEditing ? 'Updated' : 'Added'} schedule')),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _toggleTools() {
    setState(() {
      _showTools = !_showTools;
    });
  }

  void _selectDay(String day) {
    setState(() {
      _selectedDay = day;
    });
  }

  Widget _buildDayButton(String day) {
    return ElevatedButton(
      onPressed: () => _selectDay(day),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedDay == day ? const Color(0xFF667EEA) : Colors.grey[300],
        foregroundColor: _selectedDay == day ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        day.substring(0, 3), // Show first 3 letters
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredSchedules = _selectedDay == null || _selectedDay == ''
        ? _schedules
        : _schedules.where((s) => s.day == _selectedDay).toList();

    return Column(
      children: [
        // Toggle Tools Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Schedule Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _toggleTools,
                icon: Icon(_showTools ? Icons.close : Icons.filter_list),
                label: Text(_showTools ? 'Hide Tools' : 'Show Tools'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (_showTools)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Filter by Day',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDayButton('Monday'),
                    _buildDayButton('Tuesday'),
                    _buildDayButton('Wednesday'),
                    _buildDayButton('Thursday'),
                    _buildDayButton('Friday'),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedDay = null),
                  child: const Text('Show All'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _addSchedule,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Schedule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredSchedules.length,
            itemBuilder: (context, index) {
              final schedule = filteredSchedules[index];
              final teacher = _teachers.firstWhere(
                (t) => t.id == schedule.assignedToId,
                orElse: () => User(id: '', username: '', password: '', role: UserRole.teacher, name: 'Unknown'),
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text('${schedule.subject} - ${schedule.className}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Teacher: ${teacher.name}'),
                      Text('${schedule.day} ${schedule.time} - Room ${schedule.room}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editSchedule(schedule);
                          break;
                        case 'delete':
                          _deleteSchedule(schedule);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
