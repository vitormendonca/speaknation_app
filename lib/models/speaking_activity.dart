class SpeakingActivity {
  final String id;
  final String title;
  final String description;
  final String level;
  final String prompt;
  final String targetLanguage;
  final String preparationTip;
  final List<String> checklist;

  const SpeakingActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.prompt,
    required this.targetLanguage,
    required this.preparationTip,
    required this.checklist,
  });
}
