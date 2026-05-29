import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
import '../listening/listening_screen.dart';
import '../reading/reading_screen.dart';
import '../vocabulary/vocabulary_screen.dart';
import 'student_assignments_screen.dart';
import 'student_profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String currentStudentName = '';

  int totalPending = 0;
  int totalCompleted = 0;
  int totalReviewNeeded = 0;

  bool isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStudentName = prefs.getString('currentStudentName') ?? '';

    final List<AssignedActivity> assignments =
        await AssignmentService.getAssignedActivitiesByStudentName(
      savedStudentName,
    );

    if (!mounted) return;

    setState(() {
      currentStudentName = savedStudentName;

      totalPending = assignments
          .where((assignment) => assignment.status == 'Pending')
          .length;

      totalCompleted = assignments
          .where((assignment) => assignment.status == 'Completed')
          .length;

      totalReviewNeeded = assignments
          .where((assignment) => assignment.status == 'Review Needed')
          .length;

      isLoadingProgress = false;
    });
  }

  Future<void> refreshProgress() async {
    setState(() {
      isLoadingProgress = true;
    });

    await loadProgress();
  }

  void openScreen(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );

    await refreshProgress();
  }

  int get totalHomework {
    return totalPending + totalCompleted + totalReviewNeeded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Student Home'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'My Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              openScreen(
                context,
                const StudentProfileScreen(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshProgress,
        color: const Color(0xFFB00020),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB00020).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Color(0xFFB00020),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentStudentName.isEmpty
                              ? 'Check your homework and keep practicing.'
                              : 'Continue your learning journey, $currentStudentName.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Homework',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (isLoadingProgress)
                    const Text(
                      'Loading homework...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    )
                  else ...[
                    progressItem(
                      icon: Icons.assignment,
                      label: 'Total Homework',
                      value: totalHomework,
                      color: totalHomework > 0 ? Colors.white : Colors.white54,
                      onTap: () {
                        openScreen(
                          context,
                          const StudentAssignmentsScreen(),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    progressItem(
                      icon: Icons.schedule,
                      label: 'Pending Homework',
                      value: totalPending,
                      color: totalPending > 0
                          ? Colors.amberAccent
                          : Colors.white54,
                      onTap: () {
                        openScreen(
                          context,
                          const StudentAssignmentsScreen(),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    progressItem(
                      icon: Icons.check_circle_outline,
                      label: 'Completed Homework',
                      value: totalCompleted,
                      color: totalCompleted > 0
                          ? Colors.greenAccent
                          : Colors.white54,
                      onTap: () {
                        openScreen(
                          context,
                          const StudentAssignmentsScreen(),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    progressItem(
                      icon: Icons.rate_review_outlined,
                      label: 'Review Needed',
                      value: totalReviewNeeded,
                      color: totalReviewNeeded > 0
                          ? Colors.orangeAccent
                          : Colors.white54,
                      onTap: () {
                        openScreen(
                          context,
                          const StudentAssignmentsScreen(),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 12),

                  const Text(
                    'Homework is assigned by your teacher and can include listening, vocabulary, reading, or written activities.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'My Homework',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            homeCard(
              context: context,
              icon: Icons.assignment_turned_in,
              title: 'Open Homework',
              description:
                  'Open the official activities assigned by your teacher.',
              onTap: () {
                openScreen(
                  context,
                  const StudentAssignmentsScreen(),
                );
              },
            ),

            const SizedBox(height: 12),

            const Text(
              'Practice Yourself',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Practice freely. These activities help you continue your learning path outside homework.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),

            homeCard(
              context: context,
              icon: Icons.headphones,
              title: 'Listening',
              description: 'Practice listening with audio exercises.',
              onTap: () {
                openScreen(
                  context,
                  const ListeningScreen(),
                );
              },
            ),

            homeCard(
              context: context,
              icon: Icons.quiz,
              title: 'Vocabulary',
              description: 'Review words and test your vocabulary.',
              onTap: () {
                openScreen(
                  context,
                  const VocabularyScreen(),
                );
              },
            ),

            homeCard(
              context: context,
              icon: Icons.menu_book,
              title: 'Reading',
              description: 'Read texts and answer comprehension questions.',
              onTap: () {
                openScreen(
                  context,
                  const ReadingScreen(),
                );
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget progressItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    VoidCallback? onTap,
  }) {
    final bool isClickable = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isClickable ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight:
                        isClickable ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isClickable) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white38,
                  size: 14,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget homeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB00020).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFB00020),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
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
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white38,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}