import '../models/activity_question.dart';
import '../models/listening_exercise.dart';

const List<ListeningExercise> listeningExercises = [
  ListeningExercise(
    id: 'listening_001',
    title: 'Morning Routine',
    description: 'Listen to a short audio about a daily routine.',
    level: 'A1',
    audioPath: 'audio/morning_routine.mp3',
    transcript:
        'Anna wakes up at seven o’clock every morning. She has breakfast and goes to work by bus.',
    questions: [
      ActivityQuestion(
        id: 'listening_001_q1',
        type: QuestionType.multipleChoice,
        question: 'What time does Anna wake up?',
        options: [
          'At six o’clock',
          'At seven o’clock',
          'At nine o’clock',
        ],
        correctAnswer: 'At seven o’clock',
      ),
      ActivityQuestion(
        id: 'listening_001_q2',
        type: QuestionType.multipleChoice,
        question: 'How does Anna go to work?',
        options: [
          'By car',
          'By bus',
          'By bike',
        ],
        correctAnswer: 'By bus',
      ),
      ActivityQuestion(
        id: 'listening_001_q3',
        type: QuestionType.dictation,
        question:
            'Listen and type this sentence: Anna wakes up at seven o’clock.',
        options: [],
        correctAnswer: 'Anna wakes up at seven o’clock',
      ),
    ],
  ),
  ListeningExercise(
    id: 'listening_002',
    title: 'At the Restaurant',
    description: 'Listen to a short conversation at a restaurant.',
    level: 'A2',
    audioPath: 'audio/restaurant.mp3',
    transcript:
        'The waiter gives Mark and Julia the menu. Mark orders chicken with rice, and Julia orders pasta.',
    questions: [
      ActivityQuestion(
        id: 'listening_002_q1',
        type: QuestionType.multipleChoice,
        question: 'Where are Mark and Julia?',
        options: [
          'At school',
          'At a restaurant',
          'At the airport',
        ],
        correctAnswer: 'At a restaurant',
      ),
      ActivityQuestion(
        id: 'listening_002_q2',
        type: QuestionType.multipleChoice,
        question: 'What does Julia order?',
        options: [
          'Pasta',
          'Chicken with rice',
          'Soup',
        ],
        correctAnswer: 'Pasta',
      ),
      ActivityQuestion(
        id: 'listening_002_q3',
        type: QuestionType.dictation,
        question: 'Listen and type this sentence: Julia orders pasta.',
        options: [],
        correctAnswer: 'Julia orders pasta',
      ),
    ],
  ),
];