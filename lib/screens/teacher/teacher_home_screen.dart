import 'package:flutter/material.dart';

import '../../data/listening_data.dart';
import '../../data/vocabulary_data.dart';
import '../../data/homework_data.dart';
import '../../data/reading_data.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int listeningCount = listeningExercises.length;
    final int vocabularyCount = vocabularyQuizzes.length;
    final int readingCount = readingActivities.length;
    final int homeworkCount = homeworkActivities.length;

    final int totalActivities =
        listeningCount + vocabularyCount + readingCount + homeworkCount;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Teacher Area'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, teacher!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Manage and offer extra English practice to your students.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _sectionCard(
            title: 'Content Summary',
            children: [
              summaryRow(
                icon: Icons.headphones,
                title: 'Listening activities',
                value: listeningCount.toString(),
              ),
              summaryRow(
                icon: Icons.quiz,
                title: 'Vocabulary quizzes',
                value: vocabularyCount.toString(),
              ),
              summaryRow(
                icon: Icons.menu_book,
                title: 'Reading activities',
                value: readingCount.toString(),
              ),
              summaryRow(
                icon: Icons.assignment,
                title: 'Homework activities',
                value: homeworkCount.toString(),
              ),
              const Divider(color: Colors.white12, height: 28),
              summaryRow(
                icon: Icons.dashboard,
                title: 'Total activities',
                value: totalActivities.toString(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionCard(
            title: 'Student Access Code',
            children: const [
              Text(
                'Share this code with your students so they can access the student area:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 16),

              SelectableText(
                'ALUNO123',
                style: TextStyle(
                  color: Color(0xFFB00020),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Temporary MVP code. In future versions, each teacher can have their own code.',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionCard(
            title: 'How to use this app',
            children: const [
              Text(
                'Use this app as extra practice after your classes. Students can review listening, vocabulary, reading and homework activities at home.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 12),

              Text(
                'In future versions, teachers will be able to create activities, assign tasks and follow student progress.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }

  Widget summaryRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFB00020),
            size: 28,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}