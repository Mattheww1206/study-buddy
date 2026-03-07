import 'package:flutter/material.dart';
import 'package:studybuddy/features/quiz/model/quiz_model.dart';

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  String _quizMode = 'multiple_choice';

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isFinished => _isFinished;
  String get quizMode => _quizMode;
  QuizQuestion? get currentQuestion => 
  _questions.isEmpty ? null : _questions[_currentIndex];
  int get totalQuestions => _questions.length;

  void setQuestions(List<QuizQuestion> questions, String mode) {
    _questions = questions;
    _currentIndex = 0;
    _score = 0;
    _isFinished = false;
    _quizMode = mode;
    notifyListeners();
  }

  void AnswerQuestion(String answer) {
    if(_questions[_currentIndex].isAnswered) return;

    _questions[_currentIndex].selectedAnswer = answer;

    if(_questions[_currentIndex].isCorrect) {
      _score++;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if(_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      _isFinished = true;
      notifyListeners();
    }
  }

  void clearQuiz() {
   _questions = [];
   _currentIndex = 0;
   _score = 0;
   _isFinished = false;
   notifyListeners(); 
  }


}