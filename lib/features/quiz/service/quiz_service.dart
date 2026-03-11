import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/gemini/service/gemini_service.dart';

class QuizService {
  final DeckService _deckService = DeckService();
  final GeminiService _geminiService = GeminiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Multiple Choice ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> generateMultipleChoiceQuiz({
    required String deckId,
    required int numberOfQuestions,
  }) async {
    final cards = await _deckService.getDeckFlashcards(deckId);
    cards.shuffle();
    final selected = cards.take(numberOfQuestions).toList();


    final saved = await _getFromFirestore(deckId, 'multiple_choice');
    if (saved != null) {
      print('Firestore — MC quiz for $deckId');
      return _buildMCQuizData(selected, saved);
    }

    print('Gemini generating distractors - MC quiz for $deckId');
    final flashcardMaps = selected
        .map((c) => {'question': c.question, 'answer': c.answer})
        .toList();

    final allDistractors = await _geminiService.generateDistractors(flashcards: flashcardMaps);


    await _saveMCToFirestore(deckId, selected, allDistractors);
    print('Firestore saved MC quiz for $deckId');

  
    final freshSaved = await _getFromFirestore(deckId, 'multiple_choice');
    return _buildMCQuizData(selected, freshSaved!);
  }

  // ─── Identification ─────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> generateIdentificationQuiz({
    required String deckId,
    required int numberOfQuestions,
  }) async {
    final cards = await _deckService.getDeckFlashcards(deckId);
    cards.shuffle();
    final selected = cards.take(numberOfQuestions).toList();

    // 1. Check Firestore
    final saved = await _getFromFirestore(deckId, 'identification');
    if (saved != null) {
      print('Firestore — identification quiz for $deckId');
      return _buildIdenQuizData(saved);
    }

    // 2. Call Gemini
    print('Gemini generating modified questions - identification quiz for $deckId');
    final flashcardMaps = selected
        .map((c) => {'question': c.question, 'answer': c.answer})
        .toList();

    final generated = await _geminiService.generateIdentificationQuestionsBatch(
      flashcards: flashcardMaps,
    );

    // 3. Save to Firestore
    await _saveIdenToFirestore(deckId, selected, generated);
    print('Firestore saved identification quiz for $deckId');

    // 4. Return built quiz
    final freshSaved = await _getFromFirestore(deckId, 'identification');
    return _buildIdenQuizData(freshSaved!);
  }

  // ─── Firestore Read ──────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>?> _getFromFirestore(
      String deckId, String quizType) async {
    try {
      final doc = await _firestore
          .collection('decks')
          .doc(deckId)
          .collection('generatedQuiz')
          .doc(quizType)
          .get();

      if (!doc.exists) return null;
      return List<Map<String, dynamic>>.from(doc.data()!['questions']);
    } catch (e) {
      print('Firestore error reading quiz: $e');
      return null;
    }
  }

  // ─── Firestore Write ─────────────────────────────────────────────────
  Future<void> _saveMCToFirestore(
    String deckId,
    List<Flashcard> flashcards,
    List<List<String>> distractors,
  ) async {
    final questions = List.generate(flashcards.length, (i) => {
      'flashcardId': flashcards[i].cardId,
      'question': flashcards[i].question,
      'correctAnswer': flashcards[i].answer,
      'distractors': distractors[i],
    });

    await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('generatedQuiz')
        .doc('multiple_choice')
        .set({
      'generatedAt': FieldValue.serverTimestamp(),
      'questions': questions,
    });
  }

  Future<void> _saveIdenToFirestore(
    String deckId,
    List<Flashcard> flashcards,
    List<Map<String, String>> generated,
  ) async {
    final questions = List.generate(flashcards.length, (i) => {
      'flashcardId': flashcards[i].cardId,
      'question': generated[i]['question'] ?? flashcards[i].question,
      'answer': generated[i]['answer'] ?? flashcards[i].answer,
    });

    await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('generatedQuiz')
        .doc('identification')
        .set({
      'generatedAt': FieldValue.serverTimestamp(),
      'questions': questions,
    });
  }

  // ─── Build Quiz Data ──────────────────────────────────────────────────
  List<Map<String, dynamic>> _buildMCQuizData(
    List<Flashcard> flashcards,
    List<Map<String, dynamic>> saved,
  ) {
    // align saved questions to shuffled flashcards by flashcardId
    return List.generate(flashcards.length, (i) {
      final match = saved.firstWhere(
        (s) => s['flashcardId'] == flashcards[i].cardId,
        orElse: () => saved[i],
      );
      final choices = [
        match['correctAnswer'].toString(),
        ...List<String>.from(match['distractors']),
      ]..shuffle();
      return {
        'flashcard': flashcards[i],
        'choices': choices,
        'correctAnswer': match['correctAnswer'],
        'selectedAnswer': null,
      };
    });
  }

  List<Map<String, dynamic>> _buildIdenQuizData(
    List<Map<String, dynamic>> saved,
  ) {
    return saved.map((q) => {
      'question': q['question'],
      'correctAnswer': q['answer'],
      'userAnswer': '',
      'isCorrect': false,
    }).toList();
  }

  // ─── Delete when deck is edited ───────────────────────────────────────
  Future<void> deleteGeneratedQuiz(String deckId) async {
    final types = ['multiple_choice', 'identification'];
    for (final type in types) {
      await _firestore
          .collection('decks')
          .doc(deckId)
          .collection('generatedQuiz')
          .doc(type)
          .delete();
    }
    print('Firestore deletes generated quizzes for $deckId');
  }

  // ─── Wrong Answers (unchanged) ────────────────────────────────────────
  List<Map<String, String>> getWrongAnswers(
      List<Map<String, dynamic>> quizData) {
    final wrongAnswers = <Map<String, String>>[];
    for (final data in quizData) {
      final selected = data['selectedAnswer'] as String?;
      final correct = data['correctAnswer'] as String;
      final flashcard = data['flashcard'] as Flashcard;
      if (selected != null && selected != correct) {
        wrongAnswers.add({
          'question': flashcard.question,
          'correctAnswer': correct,
          'selectedAnswer': selected,
        });
      }
    }
    return wrongAnswers;
  }
}