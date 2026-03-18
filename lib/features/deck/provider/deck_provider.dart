import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class DeckProvider extends ChangeNotifier {
  final DeckService _deckService = DeckService();

  // ─── Internal State ──────────────────────────────────────────────
  List<Deck> _decks = [];
  Deck? _selectedDeck;
  List<Flashcard> _currentFlashcards = [];
  final Set<String> _pendingDeletions = {};
  final Set<String> _pendingCardDeletions = {};

  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<Deck>>? _decksSubscription;

  List<Deck> get decks =>
      _decks.where((d) => !_pendingDeletions.contains(d.deckId)).toList();
  Deck? get selectedDeck => _selectedDeck;
  List<Flashcard> get currentFlashcards => _currentFlashcards
      .where((c) => !_pendingCardDeletions.contains(c.cardId))
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

 
  void listenToDecks(String userId) {
    
    _decksSubscription?.cancel();

    _isLoading = true;
    _error = null;
    notifyListeners();

    _decksSubscription = _deckService.getUserDecks(userId).listen(
      (incomingDecks) {
        _decks = incomingDecks;
        _sortDecks();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _decksSubscription?.cancel();
    _decksSubscription = null;
    clearAll();
  }

  Future<Deck> createDeck({
    required String userId,
    required String title,
    required String subject,
    required List<Map<String, String>> cards,
  }) async {
    try {
      final newDeck = await _deckService.createDeck(
        userId: userId,
        title: title,
        subject: subject,
        cards: cards,
      );
     
      _decks.insert(0, newDeck);
      notifyListeners();
      return newDeck;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; 
    }
  }

  Future<void> deleteDeck(
    String deckId, {
    required String userId,
    required bool isOnline,
  }) async {
 
    _pendingDeletions.add(deckId);
    if (_selectedDeck?.deckId == deckId) _selectedDeck = null;
    notifyListeners();

    
    try {
      await _deckService.deleteDeck(
        deckId,
        userId: userId,
        isOnline: isOnline,
      );
    } catch (e) {
      _pendingDeletions.remove(deckId);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

 
  Future<void> updateDeck(String deckId, Map<String, dynamic> data) async {
    try {
      final index = _decks.indexWhere((d) => d.deckId == deckId);
    if (index != -1) {
      final updated = _decks[index].copyWith(
        isPinned: data['isPinned'] ?? _decks[index].isPinned,
        title: data['title'] ?? _decks[index].title,
        subject: data['subject'] ?? _decks[index].subject,
      );
      _decks[index] = updated;
      if (_selectedDeck?.deckId == deckId) {
        _selectedDeck = updated;
      }
      _sortDecks(); 
      notifyListeners();
    }
      await _deckService.updateDeck(deckId, data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void setDecks(List<Deck> incomingDecks) {
  _decks = incomingDecks.map((incoming) {
    final existing = _decks.firstWhere(
      (d) => d.deckId == incoming.deckId,
      orElse: () => incoming,
    );
    if (_pendingDeletions.contains(incoming.deckId)) return incoming;
    return incoming;
  }).toList();

  _sortDecks(); 
  notifyListeners();
}

  void addDeck(Deck deck) {
  _decks.insert(0, deck);
  _sortDecks(); // ✅
  notifyListeners();
}


void updateDecks(Deck updatedDeck) {
  if (_pendingDeletions.contains(updatedDeck.deckId)) return;
  final index = _decks.indexWhere((d) => d.deckId == updatedDeck.deckId);
  if (index != -1) {
    _decks[index] = updatedDeck;
    if (_selectedDeck?.deckId == updatedDeck.deckId) {
      _selectedDeck = updatedDeck;
    }
    _sortDecks(); // ✅
    notifyListeners();
  }
}


 

  Future<void> loadFlashcards(String deckId) async {
    try {
      final cards = await _deckService.getDeckFlashcards(deckId);
      _currentFlashcards = cards;
      _pendingCardDeletions.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void removeFlashcard(String cardId) {
    _pendingCardDeletions.add(cardId);
    if (_selectedDeck != null) {
      _selectedDeck = _selectedDeck!.copyWith(
        totalCards: (_selectedDeck!.totalCards - 1).clamp(0, 999),
      );
    }
    notifyListeners();
  }

  void confirmCardDeletion(String cardId) {
    _pendingCardDeletions.remove(cardId);
    notifyListeners();
  }
  
  void selectDeck(Deck deck) {
    _selectedDeck = deck;
    notifyListeners();
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAll() {
    _decks = [];
    _selectedDeck = null;
    _currentFlashcards = [];
    _pendingDeletions.clear();
    _pendingCardDeletions.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _decksSubscription?.cancel();
    super.dispose();
  }

  void _sortDecks() {
  _decks.sort((a, b) {
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;
    return b.createdAt.compareTo(a.createdAt);
  });
}
}