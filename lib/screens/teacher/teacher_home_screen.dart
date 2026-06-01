import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/app_ui.dart';
import 'teacher_profile_screen.dart';
import 'teacher_students_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$featureName will be available soon.')),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(ThemeController.iconFor(context)),
            onPressed: () => ThemeController.toggle(context),
          ),
          IconButton(
            tooltip: 'Teacher Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              _openScreen(context, const TeacherProfileScreen());
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppSectionHeader(
            title: 'Welcome, Teacher',
            subtitle:
                'Manage your students, classes, activities and progress from here.',
          ),
          const SizedBox(height: 22),
          AppActionTile(
            icon: Icons.person_outline,
            color: AppTheme.brandRed,
            title: 'Students',
            subtitle:
                'View students, assign activities and check individual progress.',
            onTap: () {
              _openScreen(context, const TeacherStudentsScreen());
            },
          ),
          AppActionTile(
            icon: Icons.groups_outlined,
            color: AppTheme.info,
            title: 'Classes',
            subtitle: 'Manage groups, class schedules and class activities.',
            onTap: () => _showComingSoon(context, 'Classes'),
          ),
          AppActionTile(
            icon: Icons.assignment_outlined,
            color: AppTheme.warning,
            title: 'Activities',
            subtitle:
                'View available homework, listening and vocabulary activities.',
            onTap: () => _showComingSoon(context, 'Activities'),
          ),
          AppActionTile(
            icon: Icons.query_stats_outlined,
            color: AppTheme.success,
            title: 'Progress',
            subtitle: 'Track completed activities and student development.',
            onTap: () => _showComingSoon(context, 'Progress'),
          ),
        ],
      ),
    );
  }
}
