import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import 'teacher_assigned_activities_screen.dart';
import 'teacher_students_screen.dart';

class AddAssignmentScreen extends StatelessWidget {
  const AddAssignmentScreen({super.key});

  void _goToStudents(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TeacherStudentsScreen()),
    );
  }

  void _openAssignedActivities(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TeacherAssignedActivitiesScreen(),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppIconBox(icon: Icons.info_outline, color: AppTheme.info),
          const SizedBox(height: 16),
          Text(
            'New assignment flow',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Assignments are now created from the student profile. This makes the process easier because the app already knows which student will receive the activity.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to assign an activity',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const _StepItem(number: '1', text: 'Go to Students.'),
          const _StepItem(number: '2', text: 'Choose a student.'),
          const _StepItem(number: '3', text: 'Tap Assign Activity.'),
          const _StepItem(
            number: '4',
            text: 'Choose the activity and confirm.',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Assignment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppSectionHeader(
            title: 'Add Assignment',
            subtitle:
                'Assignments start from a student profile so the teacher keeps the right context.',
          ),
          const SizedBox(height: 20),
          _buildInfoCard(context),
          const SizedBox(height: 20),
          _buildStepsCard(context),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _goToStudents(context),
              icon: const Icon(Icons.people_outline),
              label: const Text('Go to Students'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _openAssignedActivities(context),
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('View Assigned Activities'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;

  const _StepItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.brandRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(
                color: AppTheme.brandRed.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: AppTheme.brandRed,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
