class AssignedActivity {
  final String id;

  final String title;
  final String category; // Listening, Vocabulary, Reading, Homework
  final String level;

  final String assignedToName;
  final String assignedToType; // Student or Class

  final String dueDate;
  final String status; // Pending, Completed, Review Needed

  final String note;

  const AssignedActivity({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.assignedToName,
    required this.assignedToType,
    required this.dueDate,
    required this.status,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'level': level,
      'assignedToName': assignedToName,
      'assignedToType': assignedToType,
      'dueDate': dueDate,
      'status': status,
      'note': note,
    };
  }

  factory AssignedActivity.fromJson(Map<String, dynamic> json) {
    return AssignedActivity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      assignedToName: json['assignedToName'] ?? '',
      assignedToType: json['assignedToType'] ?? 'Student',
      dueDate: json['dueDate'] ?? 'No due date',
      status: json['status'] ?? 'Pending',
      note: json['note'] ?? '',
    );
  }
}