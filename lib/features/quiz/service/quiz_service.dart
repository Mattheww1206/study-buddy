import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/gemini/service/gemini_service.dart';


class QuizService {
  final DeckService _deckService = DeckService();
  final GeminiService _geminiService = GeminiService();

  Future<List<Map<String, dynamic>>> generateMultipleChoiceQuiz({
    required String deckId,
    required int numberOfQuestions,
  }) async {
    final cards = await _deckService.getDeckFlashcards(deckId);
    cards.shuffle();
    final selected = cards.take(numberOfQuestions).toList();

    final flashcardMaps = selected.map((card) => {'question': card.question, 'answer': card.answer}).toList();

    final allDistractors = await _geminiService.generateDistractors(flashcards: flashcardMaps);

    final quizData = List.generate(selected.length, (i) {
      final card = selected[i];
      final distractors = allDistractors[i];
      final choices = [card.answer, ...distractors]..shuffle();
      return {
        'flashcard': card,
        'choices': choices,
        'selectedAnswer': null,
        'correctAnswer': card.answer,
      };
    });
    return quizData;
  }


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


  Future<List<Map<String, dynamic>>> generateIdentificationQuiz({
  required String deckId,
  required int numberOfQuestions,
}) async {
  final cards = List<Flashcard>.from(
    await _deckService.getDeckFlashcards(deckId),
  );
  cards.shuffle();
  final selected = cards.take(numberOfQuestions).toList();

  // 👇 one batch call instead of Future.wait per card
  final flashcardsInput = selected.map((card) => {
    'question': card.question,
    'answer': card.answer,
  }).toList();

  final generated = await _geminiService.generateIdentificationQuestionsBatch(
    flashcards: flashcardsInput,
  );

  return List.generate(selected.length, (i) => {
    'flashcard': selected[i],
    'question': generated[i]['question'],
    'correctAnswer': generated[i]['answer'],
    'userAnswer': '',
    'isCorrect': false,
  });
}


 }