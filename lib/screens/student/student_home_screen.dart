import 'package:flutter/material.dart';

import '../../widgets/practice_card.dart';
import '../homework/homework_screen.dart';
import '../listening/listening_screen.dart';
import '../reading/reading_screen.dart';
import '../vocabulary/vocabulary_screen.dart';
import 'student_profile_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  void openScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Student Area'),
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
                  'Welcome, student!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Practice English with listening, vocabulary, reading, and homework activities.',
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

          PracticeCard(
            title: 'My Profile',
            description: 'View your progress, achievements, and learning journey.',
            icon: Icons.person,
            onTap: () {
              openScreen(context, const StudentProfileScreen());
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Practice areas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          PracticeCard(
            title: 'Listening Practice',
            description: 'Listen, answer questions, and practice comprehension.',
            icon: Icons.headphones,
            onTap: () {
              openScreen(context, const ListeningScreen());
            },
          ),

          PracticeCard(
            title: 'Vocabulary Practice',
            description: 'Build vocabulary with themed quizzes and scores.',
            icon: Icons.quiz,
            onTap: () {
              openScreen(context, const VocabularyScreen());
            },
          ),

          PracticeCard(
            title: 'Reading Practice',
            description: 'Read short texts and practice comprehension.',
            icon: Icons.menu_book,
            onTap: () {
              openScreen(context, const ReadingScreen());
            },
          ),

          PracticeCard(
            title: 'Homework Support',
            description: 'Complete extra practice assigned by your teacher.',
            icon: Icons.assignment,
            onTap: () {
              openScreen(context, const HomeworkScreen());
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}