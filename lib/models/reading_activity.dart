import 'activity_question.dart';

class ReadingActivity {
  final String id;
  final String title;
  final String description;
  final String level;

  // Main reading text shown to the student.
  final String text;

  // Questions connected to this reading activity.
  final List<ActivityQuestion> questions;

  const ReadingActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.text,
    required this.questions,
  });
}