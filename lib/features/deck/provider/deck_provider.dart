import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class DeckProvider extends ChangeNotifier {
  List<Deck> _decks = [];
  Deck? _selectedDeck;
  List<Flashcard> _currentFlashcards = [];
  final Set<String> _pendingDeletions = {}; // Our "Security Guard" list
  final Set<String> _pendingCardDeletions = {}; // Our "Security Guard" list

  // Getters
  // We filter here to ensure the UI NEVER sees a pending deleted deck
  List<Deck> get decks => _decks.where((d) => !_pendingDeletions.contains(d.deckId)).toList();
  Deck? get selectedDeck => _selectedDeck;
  List<Flashcard> get currentFlashcards => _currentFlashcards
      .where((card) => !_pendingCardDeletions.contains(card.cardId))
      .toList();

  // --- SETTERS ---

  void setDecks(List<Deck> incomingDecks) {
    // Store all, but our getter 'decks' will handle the filtering
    _decks = incomingDecks;
    notifyListeners();
  }

  void addDeck(Deck deck) {
    _decks.insert(0, deck);
    notifyListeners();
  }

  void selectDeck(Deck deck) {
    _selectedDeck = deck;
    notifyListeners();
  }

  void setCurrentFlashcard(List<Flashcard> cards) {
    _currentFlashcards = cards;
    notifyListeners();
  }

  // --- DELETION LOGIC ---

  /// This is the main method to call for deletions. 
  /// It hides the deck immediately without waiting for Firestore.
  void removeDecks(String deckId) {
    _pendingDeletions.add(deckId);
    
    // Cleanup if the deleted deck was the one currently open
    if (_selectedDeck?.deckId == deckId) {
      _selectedDeck = null;
    }
    notifyListeners();
  }

  void removeFlashcard(String cardId) {
    _pendingCardDeletions.add(cardId);
    
    // Optional: Also update the 'totalCards' count of the selected deck 
    // locally so the UI updates the "10 Flashcards" text immediately.
    if (_selectedDeck != null) {
      _selectedDeck = _selectedDeck!.copyWith(
        totalCards: (_selectedDeck!.totalCards - 1).clamp(0, 999),
      );
    }
    
    notifyListeners();
  }

  /// Optional: Call this if you want to clear the 'blacklist' once 
  /// you are sure the server has synced.
  void confirmDeletion(String deckId) {
    _pendingDeletions.remove(deckId);
  }

  void confirmCardDeletion(String cardId) {
    _pendingCardDeletions.remove(cardId);
  }

  // --- UPDATES ---

  void updateDecks(Deck updatedDeck) {
    // Safety check: Don't update/show a deck if it's pending deletion
    if (_pendingDeletions.contains(updatedDeck.deckId)) return;

    final index = _decks.indexWhere((d) => d.deckId == updatedDeck.deckId);
    if (index != -1) {
      _decks[index] = updatedDeck;
      
      // Update selectedDeck too if it's the same one
      if (_selectedDeck?.deckId == updatedDeck.deckId) {
        _selectedDeck = updatedDeck;
      }
      notifyListeners();
    }
  }

  void clearDecks() {
    _decks = [];
    _selectedDeck = null;
    _currentFlashcards = [];
    _pendingDeletions.clear();
    _pendingCardDeletions.clear();
    notifyListeners();
  }
}