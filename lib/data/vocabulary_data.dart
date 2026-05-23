import '../models/activity_question.dart';
import '../models/vocabulary_quiz.dart';

const List<VocabularyQuiz> vocabularyQuizzes = [
  VocabularyQuiz(
    id: 'restaurant_vocabulary_001',
    title: 'Restaurant Vocabulary',
    description: 'Practice useful words for restaurants and ordering food.',
    level: 'A1/A2',
    questions: [
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q1',
        type: QuestionType.multipleChoice,
        question: 'What does "menu" mean?',
        options: [
          'Cardápio',
          'Conta',
          'Mesa',
        ],
        correctAnswer: 'Cardápio',
      ),
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q2',
        type: QuestionType.multipleChoice,
        question: 'What does "waiter" mean?',
        options: [
          'Cliente',
          'Garçom',
          'Cozinheiro',
        ],
        correctAnswer: 'Garçom',
      ),
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q3',
        type: QuestionType.multipleChoice,
        question: 'What does "bill" mean in a restaurant?',
        options: [
          'Prato',
          'Conta',
          'Bebida',
        ],
        correctAnswer: 'Conta',
      ),
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q4',
        type: QuestionType.multipleChoice,
        question: 'Choose the correct translation: "I would like water."',
        options: [
          'Eu gostaria de água.',
          'Eu preciso da conta.',
          'Eu quero o cardápio.',
        ],
        correctAnswer: 'Eu gostaria de água.',
      ),
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q5',
        type: QuestionType.fillBlank,
        question: 'Complete: I would like a cup of ____.',
        options: [],
        correctAnswer: 'coffee',
      ),
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q6',
        type: QuestionType.multipleChoice,
        question: 'What does "table" mean?',
        options: [
          'Mesa',
          'Cadeira',
          'Prato',
        ],
        correctAnswer: 'Mesa',
      ),
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q7',
        type: QuestionType.trueFalse,
        question: '"Dessert" means sobremesa.',
        options: [
          'True',
          'False',
        ],
        correctAnswer: 'True',
      ),
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q8',
        type: QuestionType.multipleChoice,
        question: 'What do you say when you want to order food?',
        options: [
          'Can I order, please?',
          'Where is the airport?',
          'I am from Brazil.',
        ],
        correctAnswer: 'Can I order, please?',
      ),
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q9',
        type: QuestionType.textInput,
        question: 'Translate to English: "Eu gostaria da conta."',
        options: [],
        correctAnswer: 'I would like the bill',
      ),
      ActivityQuestion(
        id: 'restaurant_vocabulary_001_q10',
        type: QuestionType.multipleChoice,
        question: 'What does "chicken with rice" mean?',
        options: [
          'Frango com arroz',
          'Peixe com batata',
          'Carne com salada',
        ],
        correctAnswer: 'Frango com arroz',
      ),
    ],
  ),
];