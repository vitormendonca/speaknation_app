import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../models/activity_question.dart';
import '../../models/listening_exercise.dart';
import '../../services/student_progress_service.dart';

class ListeningExerciseScreen extends StatefulWidget {
  final ListeningExercise exercise;

  const ListeningExerciseScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ListeningExerciseScreen> createState() =>
      _ListeningExerciseScreenState();
}

class _ListeningExerciseScreenState extends State<ListeningExerciseScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();

  final Map<String, String> selectedAnswers = {};
  final Map<String, TextEditingController> textControllers = {};

  bool showTranscript = false;
  bool isPlaying = false;
  bool showResult = false;

  @override
  void initState() {
    super.initState();

    audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();

    for (final controller in textControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  TextEditingController _getController(String questionId) {
    if (!textControllers.containsKey(questionId)) {
      textControllers[questionId] = TextEditingController();
    }

    return textControllers[questionId]!;
  }

  bool _isCorrect(ActivityQuestion question, String userAnswer) {
    return userAnswer.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();
  }

  bool _isQuestionAvailable(ActivityQuestion question) {
    return question.type != QuestionType.reorderSentence;
  }

  int _availableQuestionsTotal() {
    return widget.exercise.questions
        .where((question) => _isQuestionAvailable(question))
        .length;
  }

  bool _allQuestionsAnswered() {
    for (final question in widget.exercise.questions) {
      if (!_isQuestionAvailable(question)) {
        continue;
      }

      final answer = selectedAnswers[question.id];

      if (answer == null || answer.trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  int _calculateScore() {
    int score = 0;

    for (final question in widget.exercise.questions) {
      if (!_isQuestionAvailable(question)) {
        continue;
      }

      final userAnswer = selectedAnswers[question.id];

      if (userAnswer != null && _isCorrect(question, userAnswer)) {
        score++;
      }
    }

    return score;
  }

  int _calculatePercentageScore() {
    final int score = _calculateScore();
    final int total = _availableQuestionsTotal();

    if (total == 0) {
      return 0;
    }

    return ((score / total) * 100).round();
  }

  Future<void> _saveResult() async {
    final int percentageScore = _calculatePercentageScore();

    if (percentageScore >= 85) {
      await StudentProgressService.markActivityAsCompleted(
        activityId: widget.exercise.id,
        category: 'listening',
      );
    }

    await StudentProgressService.saveActivityScore(
      activityId: widget.exercise.id,
      category: 'listening',
      score: percentageScore,
    );
  }

  Future<void> _finishListening() async {
    if (!_allQuestionsAnswered()) return;

    await _saveResult();

    if (!mounted) return;

    setState(() {
      showResult = true;
    });
  }

  void _restartActivity() {
    setState(() {
      showResult = false;
      selectedAnswers.clear();

      for (final controller in textControllers.values) {
        controller.clear();
      }
    });
  }

  void toggleTranscript() {
    setState(() {
      showTranscript = !showTranscript;
    });
  }

  Future<void> playAudio() async {
    try {
      await audioPlayer.play(
        AssetSource(widget.exercise.audioPath),
      );

      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      showAudioError(e);
    }
  }

  Future<void> pauseAudio() async {
    try {
      await audioPlayer.pause();

      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      showAudioError(e);
    }
  }

  Future<void> restartAudio() async {
    try {
      await audioPlayer.stop();

      await audioPlayer.play(
        AssetSource(widget.exercise.audioPath),
      );

      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      showAudioError(e);
    }
  }

  void showAudioError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao tocar áudio: $error'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.exercise.title),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.exercise.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.exercise.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            widget.exercise.level,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          _buildAudioCard(),

          if (showTranscript) ...[
            const SizedBox(height: 16),
            _buildTranscriptCard(),
          ],

          const SizedBox(height: 28),

          const Text(
            'Questions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          for (final question in widget.exercise.questions)
            _buildQuestion(question),

          const SizedBox(height: 24),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _allQuestionsAnswered() ? _finishListening : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB00020),
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Check Answers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            isPlaying ? Icons.graphic_eq : Icons.headphones,
            color: const Color(0xFFB00020),
            size: 72,
          ),

          const SizedBox(height: 8),

          Text(
            isPlaying ? 'Audio playing...' : 'Ready to listen',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isPlaying ? pauseAudio : playAudio,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  label: Text(
                    isPlaying ? 'Pause' : 'Play',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB00020),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: restartAudio,
                  icon: const Icon(
                    Icons.replay,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Restart',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: toggleTranscript,
            icon: Icon(
              showTranscript ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            label: Text(
              showTranscript ? 'Hide transcript' : 'Show transcript',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        widget.exercise.transcript,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildQuestion(ActivityQuestion question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        return _buildMultipleChoiceQuestion(question);

      case QuestionType.textInput:
      case QuestionType.dictation:
      case QuestionType.fillBlank:
        return _buildTextInputQuestion(question);

      case QuestionType.reorderSentence:
        return _buildComingSoonQuestion(question);
    }
  }

  Widget _buildMultipleChoiceQuestion(ActivityQuestion question) {
    final selectedAnswer = selectedAnswers[question.id];
    final hasAnswered = selectedAnswer != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          for (final option in question.options)
            _buildAnswerOption(
              question: question,
              option: option,
              selectedAnswer: selectedAnswer,
            ),

          if (hasAnswered) _buildInstantFeedback(question),
        ],
      ),
    );
  }

  Widget _buildAnswerOption({
    required ActivityQuestion question,
    required String option,
    required String? selectedAnswer,
  }) {
    final bool hasAnswered = selectedAnswer != null;
    final bool isCorrectAnswer = option == question.correctAnswer;
    final bool isSelected = option == selectedAnswer;
    final bool isWrongSelected = hasAnswered && isSelected && !isCorrectAnswer;

    Color backgroundColor = const Color(0xFF121212);
    Color borderColor = Colors.white24;
    IconData? optionIcon;

    if (hasAnswered && isCorrectAnswer) {
      backgroundColor = Colors.green.withValues(alpha: 0.25);
      borderColor = Colors.greenAccent;
      optionIcon = Icons.check_circle;
    }

    if (isWrongSelected) {
      backgroundColor = Colors.red.withValues(alpha: 0.25);
      borderColor = Colors.redAccent;
      optionIcon = Icons.cancel;
    }

    return GestureDetector(
      onTap: hasAnswered
          ? null
          : () {
              setState(() {
                selectedAnswers[question.id] = option;
              });
            },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            if (optionIcon != null)
              Icon(
                optionIcon,
                color: borderColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputQuestion(ActivityQuestion question) {
    final submittedAnswer = selectedAnswers[question.id];
    final bool hasAnswered =
        submittedAnswer != null && submittedAnswer.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _getController(question.id),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: question.type == QuestionType.dictation
                  ? 'Type what you hear'
                  : 'Type your answer here',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF121212),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFB00020)),
              ),
            ),
            onChanged: (value) {
              setState(() {
                selectedAnswers[question.id] = value;
              });
            },
          ),

          if (hasAnswered) ...[
            const SizedBox(height: 12),
            _buildInstantFeedback(question),
          ],
        ],
      ),
    );
  }

  Widget _buildInstantFeedback(ActivityQuestion question) {
    final answer = selectedAnswers[question.id];

    if (answer == null || answer.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final isCorrect = _isCorrect(question, answer);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.greenAccent : Colors.orangeAccent,
        ),
      ),
      child: Text(
        isCorrect ? 'Correct!' : 'Correct answer: ${question.correctAnswer}',
        style: TextStyle(
          color: isCorrect ? Colors.greenAccent : Colors.orangeAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildComingSoonQuestion(ActivityQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'This question type will be available soon.',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final score = _calculateScore();
    final total = _availableQuestionsTotal();
    final percentageScore = _calculatePercentageScore();
    final bool isApproved = percentageScore >= 85;

    String message;

    if (percentageScore >= 90) {
      message = 'Excellent listening comprehension! This activity is completed.';
    } else if (percentageScore >= 85) {
      message = 'Great listening comprehension! This activity is completed.';
    } else if (percentageScore >= 70) {
      message = 'Good effort. Listen again and review the transcript.';
    } else {
      message = 'Listen again and compare your answers with the transcript.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Listening Result'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isApproved ? Colors.greenAccent : Colors.orangeAccent,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isApproved ? Icons.check_circle : Icons.refresh,
                  color: isApproved ? Colors.greenAccent : Colors.orangeAccent,
                  size: 72,
                ),

                const SizedBox(height: 16),

                Text(
                  isApproved ? 'Completed' : 'Review Needed',
                  style: TextStyle(
                    color: isApproved ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Your score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '$score/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Accuracy: $percentageScore%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Review your answers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          for (int i = 0; i < widget.exercise.questions.length; i++)
            _buildReviewCard(
              index: i,
              question: widget.exercise.questions[i],
            ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _restartActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB00020),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Back to Listening',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required int index,
    required ActivityQuestion question,
  }) {
    if (!_isQuestionAvailable(question)) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${index + 1}',
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              question.question,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'This question type was not counted in this version.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final userAnswer = selectedAnswers[question.id] ?? '';
    final isCorrect = _isCorrect(question, userAnswer);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.greenAccent : Colors.redAccent,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Question ${index + 1}',
                  style: TextStyle(
                    color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Your answer: ${userAnswer.isEmpty ? 'No answer' : userAnswer}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Correct answer: ${question.correctAnswer}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}