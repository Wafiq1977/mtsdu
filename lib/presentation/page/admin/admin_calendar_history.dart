import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/calendar_event.dart';
import '../../../data/model/calendar_event_history.dart';
import '../../../presentation/provider/data_provider.dart';
import '../../../presentation/provider/auth_provider.dart';

class AdminCalendarHistory extends StatefulWidget {
  final String? eventId; // Optional: filter by specific event

  const AdminCalendarHistory({super.key, this.eventId});

  @override
  State<AdminCalendarHistory> createState() => _AdminCalendarHistoryState();
}

class _AdminCalendarHistoryState extends State<AdminCalendarHistory> {
  List<CalendarEventHistory> _history = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'created', 'updated', 'deleted'

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final allEvents = dataProvider.calendarEvents;

    List<CalendarEventHistory> allHistory = [];

    for (final event in allEvents) {
      // Filter by eventId if specified
      if (widget.eventId != null && event.id != widget.eventId) continue;

      for (final history in event.history) {
        allHistory.add(history);
      }
    }

    // Sort by timestamp (newest first)
    allHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Apply filter
    if (_selectedFilter != 'all') {
      allHistory = allHistory
          .where((h) => h.action == _selectedFilter)
          .toList();
    }

    setState(() {
      _history = allHistory;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                // Header Section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Back Button Row
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
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
                            'Riwayat Kalender',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title and Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Riwayat Perubahan Event',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 16),
                            _buildFilterDropdown(),
                          ],
                        ],
                      ),

                      // Mobile Filter
                      if (isMobile) ...[
                        const SizedBox(height: 16),
                        _buildFilterDropdown(),
                      ],
                    ],
                  ),
                ),

                // History List
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _history.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak ada riwayat perubahan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _history.length,
                                itemBuilder: (context, index) {
                                  final history = _history[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
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
                                              _buildActionIcon(history.action),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _getActionText(
                                                        history.action,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _formatDateTime(
                                                        history.timestamp,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getActionColor(
                                                    history.action,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  history.action.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _getActionColor(
                                                      history.action,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            history.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Event ID: ${history.eventId}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'User: ${history.userId}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedFilter,
        dropdownColor: const Color(0xFF667EEA),
        style: const TextStyle(color: Colors.white),
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('Semua Aksi')),
          DropdownMenuItem(value: 'created', child: Text('Dibuat')),
          DropdownMenuItem(value: 'updated', child: Text('Diubah')),
          DropdownMenuItem(value: 'deleted', child: Text('Dihapus')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedFilter = value!;
            _loadHistory();
          });
        },
      ),
    );
  }

  Widget _buildActionIcon(String action) {
    IconData icon;
    Color color;

    switch (action) {
      case 'created':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'updated':
        icon = Icons.edit;
        color = Colors.blue;
        break;
      case 'deleted':
        icon = Icons.delete;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getActionText(String action) {
    switch (action) {
      case 'created':
        return 'Event Dibuat';
      case 'updated':
        return 'Event Diubah';
      case 'deleted':
        return 'Event Dihapus';
      default:
        return 'Aksi Tidak Dikenal';
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'created':
        return Colors.green;
      case 'updated':
        return Colors.blue;
      case 'deleted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
