import 'activity_question.dart';

class ListeningExercise {
  final String id;
  final String title;
  final String description;
  final String level;

  // Path used by AssetSource.
  // Example: audio/airport_conversation.mp3
  final String audioPath;

  // Text version of the audio.
  final String transcript;

  // Questions connected to this listening exercise.
  final List<ActivityQuestion> questions;

  const ListeningExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.audioPath,
    required this.transcript,
    required this.questions,
  });
}
