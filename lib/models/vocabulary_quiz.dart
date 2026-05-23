import 'activity_question.dart';

class VocabularyQuiz {
  final String id;
  final String title;
  final String description;
  final String level;

  // Questions connected to this vocabulary quiz.
  final List<ActivityQuestion> questions;

  const VocabularyQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.questions,
  });
}