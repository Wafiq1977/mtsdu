class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentId;
  final DateTime submissionDate;
  final String? fileUrl;
  final String? description;
  final String status; // 'submitted', 'late', 'graded'

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.submissionDate,
    this.fileUrl,
    this.description,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'submissionDate': submissionDate.toIso8601String(),
      'fileUrl': fileUrl,
      'description': description,
      'status': status,
    };
  }

  factory AssignmentSubmission.fromMap(Map<String, dynamic> map) {
    return AssignmentSubmission(
      id: map['id'],
      assignmentId: map['assignmentId'],
      studentId: map['studentId'],
      submissionDate: DateTime.parse(map['submissionDate']),
      fileUrl: map['fileUrl'],
      description: map['description'],
      status: map['status'],
    );
  }
}
