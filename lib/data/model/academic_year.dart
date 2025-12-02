import 'base_model.dart';

class AcademicYear extends BaseModel {
  final String year; // Format: "2024-2025"
  final String name; // Nama tahun akademik, e.g., "Tahun Akademik 2024-2025"
  final DateTime startDate; // Tanggal mulai (biasanya Juli)
  final DateTime endDate; // Tanggal selesai (biasanya Juni tahun berikutnya)
  final String description; // Deskripsi tahun akademik
  final String createdBy; // ID user yang membuat
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive; // Apakah tahun akademik ini aktif
  final List<String>
  eventIds; // ID events yang terkait dengan tahun akademik ini

  AcademicYear({
    required String id,
    required this.year,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = false,
    this.eventIds = const [],
  }) : super(id: id);

  // Factory constructor untuk membuat AcademicYear dari Map (untuk Hive)
  factory AcademicYear.fromMap(Map<String, dynamic> map) {
    return AcademicYear(
      id: map['id'] as String,
      year: map['year'] as String,
      name: map['name'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      description: map['description'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      isActive: map['isActive'] as bool? ?? false,
      eventIds: List<String>.from(map['eventIds'] ?? []),
    );
  }

  // Method untuk convert ke Map (untuk Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'eventIds': eventIds,
    };
  }

  // Copy with method untuk immutability
  AcademicYear copyWith({
    String? id,
    String? year,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? eventIds,
  }) {
    return AcademicYear(
      id: id ?? this.id,
      year: year ?? this.year,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      eventIds: eventIds ?? this.eventIds,
    );
  }

  // Helper methods
  bool get isCurrentYear {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  String get displayName => name.isNotEmpty ? name : 'Tahun Akademik $year';

  int get startYear => int.parse(year.split('-')[0]);
  int get endYear => int.parse(year.split('-')[1]);

  @override
  String toString() {
    return 'AcademicYear(id: $id, year: $year, name: $name, isActive: $isActive)';
  }
}
