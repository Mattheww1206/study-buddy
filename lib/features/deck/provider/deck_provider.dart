import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';


class DeckProvider extends ChangeNotifier {
  List<Deck> _decks = [];
  Deck? _selectedDeck;
  List<Flashcard> _currentFlashcards = [];

  List<Deck> get decks => _decks;
  Deck? get selectedDeck => _selectedDeck;
  List<Flashcard> get currentFlashcards => _currentFlashcards;

  void addDeck(Deck deck){
    _decks.insert(0, deck);
    notifyListeners();
  }

  void setDecks(List<Deck> decks) {
    _decks = decks;
    notifyListeners();
  }

  void selectDeck(Deck deck){
    _selectedDeck = deck;
    notifyListeners();
  }

  void setCurrentFlashcard(List<Flashcard> cards){
    _currentFlashcards = cards;
    notifyListeners();
  }

  void removeDeck(String deckId) {
    _decks.removeWhere((deck) => deck.deckId == deckId);
    notifyListeners();
  }

  void clearDecks() {
    _decks = [];
    _selectedDeck = null;
    _currentFlashcards = [];
    notifyListeners();
  }


}