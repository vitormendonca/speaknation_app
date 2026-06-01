import 'package:flutter/material.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import 'teacher_assign_activity_screen.dart';
import 'teacher_student_assigned_activities_screen.dart';
import 'teacher_student_progress_screen.dart';

class TeacherStudentDetailScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentLevel;
  final String accessCode;

  const TeacherStudentDetailScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentLevel,
    required this.accessCode,
  });

  @override
  State<TeacherStudentDetailScreen> createState() =>
      _TeacherStudentDetailScreenState();
}

class _TeacherStudentDetailScreenState
    extends State<TeacherStudentDetailScreen> {
  List<AssignedActivity> assignedActivities = [];
  bool isLoadingAssignments = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedActivities();
  }

  Future<void> _loadAssignedActivities() async {
    final activities = await AssignmentService.getAssignedActivitiesForStudent(
      studentId: widget.studentId,
      studentName: widget.studentName,
    );

    if (!mounted) return;

    setState(() {
      assignedActivities = activities;
      isLoadingAssignments = false;
    });
  }

  int get totalAssigned => assignedActivities.length;

  int get pendingCount => assignedActivities
      .where((activity) => activity.status == 'Pending')
      .length;

  int get completedCount => assignedActivities
      .where(
        (activity) =>
            activity.status == 'Completed' || activity.status == 'Reviewed',
      )
      .length;

  int get reviewNeededCount => assignedActivities
      .where((activity) => activity.status == 'Review Needed')
      .length;

  Future<void> _openAssignActivityScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherAssignActivityScreen(
          studentId: widget.studentId,
          studentName: widget.studentName,
          studentLevel: widget.studentLevel,
        ),
      ),
    );

    if (!context.mounted) return;

    await _loadAssignedActivities();
  }

  Future<void> _openStudentAssignedActivitiesScreen(
    BuildContext context,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherStudentAssignedActivitiesScreen(
          studentId: widget.studentId,
          studentName: widget.studentName,
          studentLevel: widget.studentLevel,
        ),
      ),
    );

    await _loadAssignedActivities();
  }

  void _openStudentProgressScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherStudentProgressScreen(
          studentId: widget.studentId,
          studentName: widget.studentName,
          studentLevel: widget.studentLevel,
        ),
      ),
    );
  }

  Widget _studentHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initial = widget.studentName.isEmpty ? '?' : widget.studentName[0];

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppTheme.brandRed.withValues(alpha: 0.14),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppTheme.brandRed,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppStatusBadge(
                      label: 'Level ${widget.studentLevel}',
                      color: AppTheme.info,
                    ),
                    if (widget.accessCode.isNotEmpty)
                      AppStatusBadge(
                        label: widget.accessCode,
                        color: colors.onSurfaceVariant,
                        icon: Icons.key_outlined,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _assignmentSummary() {
    final String totalText = isLoadingAssignments
        ? '...'
        : totalAssigned.toString();
    final String pendingText = isLoadingAssignments
        ? '...'
        : pendingCount.toString();
    final String completedText = isLoadingAssignments
        ? '...'
        : completedCount.toString();
    final String reviewText = isLoadingAssignments
        ? '...'
        : reviewNeededCount.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Assignment Summary',
          subtitle: 'Current guidance and review state for this student.',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 640 ? 4 : 2;
            final spacing = 10.0;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: AppMetricCard(
                    title: 'Assigned',
                    value: totalText,
                    icon: Icons.assignment_outlined,
                    color: AppTheme.info,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: AppMetricCard(
                    title: 'Pending',
                    value: pendingText,
                    icon: Icons.hourglass_empty_rounded,
                    color: AppTheme.warning,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: AppMetricCard(
                    title: 'Done',
                    value: completedText,
                    icon: Icons.check_circle_outline,
                    color: AppTheme.success,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: AppMetricCard(
                    title: 'Review',
                    value: reviewText,
                    icon: Icons.rate_review_outlined,
                    color: AppTheme.warning,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh assignments',
            onPressed: _loadAssignedActivities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAssignedActivities,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _studentHeader(context),
            const SizedBox(height: 22),
            _assignmentSummary(),
            const SizedBox(height: 22),
            AppActionTile(
              icon: Icons.add_task_outlined,
              title: 'Assign Activity',
              subtitle:
                  'Choose a homework, listening or vocabulary activity for this student.',
              color: AppTheme.brandRed,
              onTap: () => _openAssignActivityScreen(context),
            ),
            AppActionTile(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Assigned Activities',
              subtitle: 'View or manage activities for this student.',
              color: AppTheme.info,
              onTap: () => _openStudentAssignedActivitiesScreen(context),
            ),
            AppActionTile(
              icon: Icons.query_stats_outlined,
              title: 'Progress',
              subtitle: 'Check completed path steps and skill performance.',
              color: AppTheme.success,
              onTap: () => _openStudentProgressScreen(context),
            ),
          ],
        ),
      ),
    );
  }
}
