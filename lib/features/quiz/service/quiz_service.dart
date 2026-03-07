import 'package:flutter/material.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/gemini/service/gemini_service.dart';
import 'package:studybuddy/features/quiz/model/quiz_model.dart';

class QuizService {
  final GeminiService _geminiService = GeminiService();

  Future<List<QuizQuestion>> buildMultipleChoice(List<Flashcard> flashcards) async {
    final List<QuizQuestion> questions = [];

    for (final card in flashcards) {
      final distractors = await _geminiService.generateDistractors(
        question: card.question, 
        correctAnswer: card.answer,
        );

        final choices = [card.answer, ...distractors]..shuffle();

        questions.add(QuizQuestion(
          flashcard: card, 
          choices: choices, 
          correctAnswer: card.answer, 
        ));
    }
    return questions;
  }

  List<QuizQuestion> buildIdentification(List<Flashcard> flashcards) {
    return flashcards.map((card) => QuizQuestion(
      flashcard: card, 
      choices: [], 
      correctAnswer: card.answer,
      )).toList();
  }

  Future<List<QuizQuestion>> buildMixQuestion(List<Flashcard> flashcards) async {
    final List<QuizQuestion> questions = [];

    for (final card in flashcards) {
      final isMultipleChoice = DateTime.now().millisecond % 2 == 0;

      if(isMultipleChoice) {
        final distractors = await _geminiService.generateDistractors(
          question: card.question, 
          correctAnswer: card.answer
          );
        final choices = [card.answer, ...distractors]..shuffle();
        questions.add(QuizQuestion(
          flashcard: card, 
          choices: choices, 
          correctAnswer: card.answer,
          ));
      } else {
        questions.add(QuizQuestion(
          flashcard: card, 
          choices: [], 
          correctAnswer: card.answer,
          ));
      }
    }
    return questions;

  }



 }