import 'package:flutter/material.dart';

import '../../data/teacher_mock_data.dart';
import '../../models/teacher_class.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';

class TeacherClassesScreen extends StatelessWidget {
  const TeacherClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Classes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppSectionHeader(
            title: 'My Classes',
            subtitle:
                'Manage your groups, class codes, schedules, and student progress.',
          ),
          const SizedBox(height: 20),
          for (final teacherClass in teacherClasses)
            _classCard(context: context, teacherClass: teacherClass),
          const SizedBox(height: 10),
          _infoCard(context),
        ],
      ),
    );
  }

  Widget _classCard({
    required BuildContext context,
    required TeacherClass teacherClass,
  }) {
    final colors = Theme.of(context).colorScheme;
    final bool needsReview = teacherClass.reviewNeeded > 0;
    final statusColor = needsReview ? AppTheme.warning : AppTheme.success;

    return AppPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconBox(icon: Icons.groups_outlined, color: statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacherClass.className,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${teacherClass.students} students - ${teacherClass.classType}',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              AppStatusBadge(
                label: needsReview ? 'Review' : 'On track',
                color: statusColor,
                icon: needsReview
                    ? Icons.rate_review_outlined
                    : Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            teacherClass.description,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(
            context: context,
            icon: Icons.key_outlined,
            title: 'Class Code',
            value: teacherClass.classCode,
          ),
          _infoRow(
            context: context,
            icon: Icons.calendar_today_outlined,
            title: 'Class Time',
            value: '${teacherClass.classDay} at ${teacherClass.classTime}',
          ),
          _infoRow(
            context: context,
            icon: Icons.repeat_outlined,
            title: 'Frequency',
            value: teacherClass.frequency,
          ),
          _infoRow(
            context: context,
            icon: Icons.computer_outlined,
            title: 'Format',
            value: teacherClass.format,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppMetricCard(
                  title: 'Completed',
                  value: teacherClass.completed.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppMetricCard(
                  title: 'Review',
                  value: teacherClass.reviewNeeded.toString(),
                  icon: Icons.rate_review_outlined,
                  color: AppTheme.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppMetricCard(
                  title: 'Average',
                  value: '${teacherClass.average}%',
                  icon: Icons.trending_up_outlined,
                  color: AppTheme.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.brandRed, size: 19),
          const SizedBox(width: 9),
          Text(
            '$title: ',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: colors.onSurface, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coming Soon',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Soon teachers will be able to create real classes, edit class codes, approve student requests, and add students by Student ID.',
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
}
