import "package:flutter/material.dart";
import "package:studybuddy/features/flashcards/model/flashcard_model.dart";

class QuizQuestion {
  final Flashcard flashcard;
  final List<String> choices;
  final String correctAnswer;
  String? selectedAnswer;

  QuizQuestion({
    required this.flashcard,
    required this.choices,
    required this.correctAnswer,
    this.selectedAnswer,
  });

  bool get isAnswered => selectedAnswer != null;
  bool get isCorrect => selectedAnswer == correctAnswer;
}