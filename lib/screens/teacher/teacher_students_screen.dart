import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import '../../services/teacher_students_service.dart';
import 'teacher_student_detail_screen.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  List<TeacherStudentSummary> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final loadedStudents =
        await TeacherStudentsService.getStudentsForCurrentTeacher();

    if (!mounted) return;

    setState(() {
      students = loadedStudents;
      isLoading = false;
    });
  }

  Future<void> _openStudent(TeacherStudentSummary student) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherStudentDetailScreen(
          studentId: student.id,
          studentName: student.name,
          studentLevel: student.level,
          accessCode: student.accessCode,
        ),
      ),
    );

    if (!mounted) return;

    await _loadStudents();
  }

  Widget _buildStudentCard(TeacherStudentSummary student) {
    final colors = Theme.of(context).colorScheme;
    final initial = student.name.isEmpty ? '?' : student.name[0];

    return AppPanel(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: () => _openStudent(student),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.brandRed.withValues(alpha: 0.14),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppTheme.brandRed,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppStatusBadge(
                            label: 'Level ${student.level}',
                            color: AppTheme.info,
                          ),
                          if (student.accessCode.isNotEmpty)
                            AppStatusBadge(
                              label: student.accessCode,
                              color: colors.onSurfaceVariant,
                              icon: Icons.key_outlined,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Icon(
            Icons.person_add_alt_1_outlined,
            color: colors.onSurfaceVariant,
            size: 50,
          ),
          const SizedBox(height: 14),
          Text(
            'No linked students yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Link a student to this teacher in Supabase to manage real assignments.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            tooltip: 'Refresh students',
            onPressed: _loadStudents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudents,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AppSectionHeader(
              title: 'Your Students',
              subtitle:
                  'Select a student to assign activities or view progress.',
            ),
            const SizedBox(height: 20),
            if (isLoading)
              _buildLoadingState()
            else if (students.isEmpty)
              _buildEmptyState()
            else
              ...students.map(_buildStudentCard),
          ],
        ),
      ),
    );
  }
}
