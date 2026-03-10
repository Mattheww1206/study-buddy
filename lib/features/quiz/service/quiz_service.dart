import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/gemini/service/gemini_service.dart';
import 'package:studybuddy/features/quiz/model/quiz_model.dart';

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

    final quizData = await Future.wait(selected.map((card) async {
      final distractors = await _geminiService.generateDistractors(
        question: card.question,
        correctAnswer: card.answer,
      );
      final choices = [card.answer, ...distractors]..shuffle();
      return {
        'flashcard': card,
        'choices': choices,
        'selectedAnswer': null,
        'correctAnswer': card.answer,
      };
    }));

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


  List<QuizQuestion> buildIdentification(List<Flashcard> flashcards) {
    return flashcards.map((card) => QuizQuestion(
      flashcard: card, 
      choices: [], 
      correctAnswer: card.answer,
      )).toList();
  }

 }