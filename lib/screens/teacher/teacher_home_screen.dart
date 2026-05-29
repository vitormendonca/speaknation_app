import 'package:flutter/material.dart';

import 'teacher_profile_screen.dart';
import 'teacher_students_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName will be available soon.'),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF6E59A5).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFD3E4FD),
                  size: 30,
                ),
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
                        fontSize: 18,
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
              const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Teacher Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              _openScreen(
                context,
                const TeacherProfileScreen(),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Welcome, Teacher',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your students, classes, activities and progress from here.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          _buildDashboardCard(
            context: context,
            icon: Icons.person,
            title: 'Students',
            subtitle:
                'View students, assign activities and check individual progress.',
            onTap: () {
              _openScreen(
                context,
                const TeacherStudentsScreen(),
              );
            },
          ),

          _buildDashboardCard(
            context: context,
            icon: Icons.groups,
            title: 'Classes',
            subtitle: 'Manage groups, class schedules and class activities.',
            onTap: () => _showComingSoon(context, 'Classes'),
          ),

          _buildDashboardCard(
            context: context,
            icon: Icons.assignment,
            title: 'Activities',
            subtitle:
                'View available homework, listening and vocabulary activities.',
            onTap: () => _showComingSoon(context, 'Activities'),
          ),

          _buildDashboardCard(
            context: context,
            icon: Icons.bar_chart,
            title: 'Progress',
            subtitle: 'Track completed activities and student development.',
            onTap: () => _showComingSoon(context, 'Progress'),
          ),
        ],
      ),
    );
  }
}