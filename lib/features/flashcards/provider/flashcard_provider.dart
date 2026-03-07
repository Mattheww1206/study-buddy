import 'package:flutter/material.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';


class FlashcardProvider extends ChangeNotifier {
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;


  List<Flashcard> get flashcards => _flashcards;
  int get currentIndex => _currentIndex;
  bool get isFlipped => _isFlipped;
  Flashcard? get currentCard => _flashcards.isEmpty ? null : _flashcards[_currentIndex];

  void setFlashcards(List<Flashcard> cards) {
    _flashcards = cards;
    _currentIndex = 0;
    _isFlipped = false;
    notifyListeners();
  }

  void flipCard () {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  void nextCard() {
    if(_currentIndex < _flashcards.length - 1){
      _currentIndex++;
      _isFlipped = false;
      notifyListeners();

    }
  }

  void previousCard() {
    if(_currentIndex > 0){
      _currentIndex--;
      _isFlipped = false;
      notifyListeners();
    }
  }

  void rateCard(String difficulty) {
    if(difficulty == 'easy') {
      _flashcards.removeAt(_currentIndex);
      if(_currentIndex >= _flashcards.length && _currentIndex > 0){
        _currentIndex--;
      }
    } else {
      final card = _flashcards.removeAt(_currentIndex);
      _flashcards.add(card);
    }
    _isFlipped = false;
    notifyListeners();
  }

  void clearFlashcards() {
    _flashcards = [];
    _currentIndex = 0;
    _isFlipped = false;
    notifyListeners();
  }


}

