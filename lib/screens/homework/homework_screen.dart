import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/homework_data.dart';
import 'homework_activity_screen.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  Map<String, bool> completedMap = {};
  Map<String, bool> correctMap = {};

  @override
  void initState() {
    super.initState();
    loadHomeworkResults();
  }

  Future<void> loadHomeworkResults() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, bool> loadedCompleted = {};
    final Map<String, bool> loadedCorrect = {};

    for (final activity in homeworkActivities) {
      loadedCompleted[activity.id] =
          prefs.getBool('${activity.id}_completed') ?? false;

      loadedCorrect[activity.id] =
          prefs.getBool('${activity.id}_correct') ?? false;
    }

    setState(() {
      completedMap = loadedCompleted;
      correctMap = loadedCorrect;
    });
  }

  Future<void> openActivity(BuildContext context, activity) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomeworkActivityScreen(
          activity: activity,
        ),
      ),
    );

    await loadHomeworkResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text('Homework'),
        backgroundColor: const Color(0xFF6E59A5),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: homeworkActivities.length,
        itemBuilder: (context, index) {
          final activity = homeworkActivities[index];

          final bool completed = completedMap[activity.id] ?? false;
          final bool correct = correctMap[activity.id] ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => openActivity(context, activity),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: completed
                            ? correct
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.orange.withValues(alpha: 0.12)
                            : const Color(0xFF6E59A5).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        completed
                            ? correct
                                ? Icons.check_circle_rounded
                                : Icons.info_rounded
                            : Icons.assignment_rounded,
                        color: completed
                            ? correct
                                ? Colors.green
                                : Colors.orange
                            : const Color(0xFF6E59A5),
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            activity.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD3E4FD),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  activity.level,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2F4B7C),
                                  ),
                                ),
                              ),

                              if (completed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: correct
                                        ? Colors.green.withValues(alpha: 0.15)
                                        : Colors.orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    correct
                                        ? 'Last result: Correct'
                                        : 'Last result: Review needed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: correct
                                          ? Colors.green.shade700
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}