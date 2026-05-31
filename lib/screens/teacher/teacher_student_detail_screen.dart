import 'package:flutter/material.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
import 'teacher_assign_activity_screen.dart';
import 'teacher_student_assigned_activities_screen.dart';

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
    final activities =
        await AssignmentService.getAssignedActivitiesByStudentName(
          widget.studentName,
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

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName will be connected soon.'),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF6E59A5).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFD3E4FD), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMiniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'ID: ${widget.studentId}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Level: ${widget.studentLevel}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Access code: ${widget.accessCode}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 18),

          const Text(
            'Assignment Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatusMiniCard(
                  title: 'Assigned',
                  value: totalText,
                  icon: Icons.assignment,
                  color: const Color(0xFFD3E4FD),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusMiniCard(
                  title: 'Pending',
                  value: pendingText,
                  icon: Icons.hourglass_empty,
                  color: Colors.amberAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildStatusMiniCard(
                  title: 'Done',
                  value: completedText,
                  icon: Icons.check_circle,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusMiniCard(
                  title: 'Review',
                  value: reviewText,
                  icon: Icons.info,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            onPressed: _loadAssignedActivities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFF6E59A5),
            child: Text(
              widget.studentName[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.studentName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Level ${widget.studentLevel}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 24),

          _buildInfoBox(),

          const SizedBox(height: 24),

          _buildActionButton(
            context: context,
            icon: Icons.add_task,
            title: 'Assign Activity',
            subtitle:
                'Choose a homework, listening or vocabulary activity for this student.',
            onTap: () => _openAssignActivityScreen(context),
          ),

          _buildActionButton(
            context: context,
            icon: Icons.assignment_turned_in,
            title: 'Assigned Activities',
            subtitle: 'View or assign activities for this student.',
            onTap: () => _openStudentAssignedActivitiesScreen(context),
          ),

          _buildActionButton(
            context: context,
            icon: Icons.bar_chart,
            title: 'Progress',
            subtitle: 'Check completed activities and student performance.',
            onTap: () => _showComingSoon(context, 'Progress'),
          ),
        ],
      ),
    );
  }
}
