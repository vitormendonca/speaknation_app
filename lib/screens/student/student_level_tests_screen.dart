import 'package:flutter/material.dart';

import '../../services/learning_path_progress_service.dart';
import '../../theme/app_theme.dart';
import 'student_placement_test_screen.dart';

class StudentLevelTestsScreen extends StatefulWidget {
  const StudentLevelTestsScreen({super.key});

  @override
  State<StudentLevelTestsScreen> createState() =>
      _StudentLevelTestsScreenState();
}

class _StudentLevelTestsScreenState extends State<StudentLevelTestsScreen> {
  Set<String> validatedLevels = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadValidatedLevels();
  }

  Future<void> _loadValidatedLevels() async {
    final levels = await LearningPathProgressService.getValidatedLevels();

    if (!mounted) return;

    setState(() {
      validatedLevels = levels;
      isLoading = false;
    });
  }

  Future<void> _validateA1() async {
    if (validatedLevels.contains('A1')) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StudentPlacementTestScreen(level: 'A1'),
      ),
    );

    await _loadValidatedLevels();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Placement Task')),
      body: RefreshIndicator(
        onRefresh: _loadValidatedLevels,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppTheme.brandRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_outlined,
                      color: AppTheme.brandRed,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Find your starting level',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Students who already know English can validate a level '
                    'with a stronger test instead of repeating every lesson.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _levelCard(
                context: context,
                level: 'A1',
                title: 'A1 Placement Task',
                description:
                    'Sample test with integrated A1 questions. Score 85% or higher '
                    'to validate this level and continue from the next path.',
                isValidated: validatedLevels.contains('A1'),
                onTap: _validateA1,
              ),
              _levelCard(
                context: context,
                level: 'A2',
                title: 'A2 Placement Task',
                description:
                    'Planned for the next level path. This will allow students '
                    'to start at A2 when they already know A1.',
                isLocked: true,
              ),
              _levelCard(
                context: context,
                level: 'B1',
                title: 'B1 Placement Task',
                description:
                    'Planned for intermediate students who should not start '
                    'from beginner content.',
                isLocked: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _levelCard({
    required BuildContext context,
    required String level,
    required String title,
    required String description,
    bool isValidated = false,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = isValidated
        ? AppTheme.success
        : isLocked
        ? colors.onSurfaceVariant
        : AppTheme.brandRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLocked || isValidated ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      level,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isValidated
                      ? Icons.check_circle_outline
                      : isLocked
                      ? Icons.lock_outline
                      : Icons.arrow_forward_ios_rounded,
                  color: statusColor,
                  size: isLocked ? 22 : 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
