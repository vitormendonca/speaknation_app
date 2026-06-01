import 'package:flutter/material.dart';

import '../../data/learning_path_data.dart';
import '../../services/learning_path_progress_service.dart';
import '../../theme/app_theme.dart';

class TeacherStudentProgressScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentLevel;

  const TeacherStudentProgressScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentLevel,
  });

  @override
  State<TeacherStudentProgressScreen> createState() =>
      _TeacherStudentProgressScreenState();
}

class _TeacherStudentProgressScreenState
    extends State<TeacherStudentProgressScreen> {
  Map<String, LearningPathSkillProgress> progressBySkill = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress =
        await LearningPathProgressService.getAllSkillProgressForStudent(
          studentId: widget.studentId,
          studentName: widget.studentName,
        );

    if (!mounted) return;

    setState(() {
      progressBySkill = progress;
      isLoading = false;
    });
  }

  int get totalCompletedSteps {
    return progressBySkill.values.fold(
      0,
      (sum, progress) => sum + progress.completedSteps,
    );
  }

  int get totalSteps {
    return progressBySkill.values.fold(
      0,
      (sum, progress) => sum + progress.totalSteps,
    );
  }

  int get totalLessonsCompleted {
    return progressBySkill.values.fold(
      0,
      (sum, progress) => sum + progress.completedLessons,
    );
  }

  int get finalTestsPassed {
    return progressBySkill.values
        .where((progress) => progress.finalTestCompleted)
        .length;
  }

  int get overallPercent {
    if (totalSteps == 0) {
      return 0;
    }

    return ((totalCompletedSteps / totalSteps) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text('Student Progress'),
        actions: [
          IconButton(
            tooltip: 'Refresh progress',
            onPressed: _loadProgress,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _headerCard(),
            const SizedBox(height: 18),
            if (isLoading)
              _loadingState()
            else ...[
              _overallCard(),
              const SizedBox(height: 18),
              const Text(
                'Learning Path',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              for (final skill in learningSkillDefinitions)
                _skillProgressCard(skill),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.brandRed,
            child: Text(
              widget.studentName.isEmpty ? '?' : widget.studentName[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${widget.studentLevel}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overallCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.query_stats_outlined,
                  color: AppTheme.info,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalCompletedSteps/$totalSteps path steps completed',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$overallPercent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: totalSteps == 0 ? 0 : totalCompletedSteps / totalSteps,
              minHeight: 9,
              color: AppTheme.info,
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  icon: Icons.play_lesson_outlined,
                  label: 'Lessons',
                  value: totalLessonsCompleted.toString(),
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryTile(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Final Tests',
                  value: '$finalTestsPassed/5',
                  color: AppTheme.brandRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillProgressCard(LearningSkillDefinition skill) {
    final progress =
        progressBySkill[skill.id] ??
        LearningPathSkillProgress(
          skillId: skill.id,
          completedLessons: 0,
          totalLessons: 12,
          completedReviews: 0,
          totalReviews: 4,
          finalTestCompleted: false,
        );

    final color = _skillColor(skill.id);
    final completedSteps = progress.completedSteps;
    final totalSkillSteps = progress.totalSteps;
    final percent = totalSkillSteps == 0
        ? 0
        : ((completedSteps / totalSkillSteps) * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_skillIcon(skill.id), color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      skill.description,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$percent%',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: totalSkillSteps == 0
                  ? 0
                  : completedSteps / totalSkillSteps,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusChip(
                label:
                    '${progress.completedLessons}/${progress.totalLessons} lessons',
                color: color,
              ),
              _statusChip(
                label:
                    '${progress.completedReviews}/${progress.totalReviews} reviews',
                color: AppTheme.warning,
              ),
              _statusChip(
                label: progress.finalTestCompleted
                    ? 'Final passed'
                    : 'Final pending',
                color: progress.finalTestCompleted
                    ? AppTheme.success
                    : Colors.white54,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _loadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(color: AppTheme.brandRed),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white10),
    );
  }

  Color _skillColor(String skillId) {
    switch (skillId) {
      case 'listening':
        return AppTheme.info;
      case 'speaking':
        return const Color(0xFF7B1FA2);
      case 'reading':
        return const Color(0xFF00897B);
      case 'vocabulary':
        return AppTheme.brandRed;
      case 'homework':
        return const Color(0xFF5E35B1);
      default:
        return AppTheme.info;
    }
  }

  IconData _skillIcon(String skillId) {
    switch (skillId) {
      case 'listening':
        return Icons.headphones_outlined;
      case 'speaking':
        return Icons.mic_none_outlined;
      case 'reading':
        return Icons.menu_book_outlined;
      case 'vocabulary':
        return Icons.style_outlined;
      case 'homework':
        return Icons.edit_note_outlined;
      default:
        return Icons.school_outlined;
    }
  }
}
