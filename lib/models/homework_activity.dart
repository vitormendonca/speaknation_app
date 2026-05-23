class HomeworkActivity {
  final String id;
  final String title;
  final String description;
  final String level;

  // Instruction shown before the question.
  final String instruction;

  // Main homework question.
  final String question;

  // Answer options shown to the student.
  final List<String> options;

  // Correct answer used to check the student response.
  final String correctAnswer;

  const HomeworkActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.instruction,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}