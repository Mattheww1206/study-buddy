import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/services/local_storage_service.dart';

class DeckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  // Create deck — saves to Firestore + local JSON
  Future<Deck> createDeck({
    required String userId,
    required String title,
    required String subject,
    required List<Map<String, String>> cards,
  }) async {
    final deckDocs = _firestore.collection('decks').doc();

    final newDeck = Deck(
      deckId: deckDocs.id,
      userId: userId,
      title: title,
      subject: subject,
      totalCards: cards.length,
      createdAt: DateTime.now(),
    );

    deckDocs.set(newDeck.toMap());

    final List<Flashcard> flashcards = [];
    for (final card in cards) {
      final cardDocs = deckDocs.collection('flashcards').doc();
      final flashcard = Flashcard(
        cardId: cardDocs.id,
        deckId: deckDocs.id,
        question: card['def']!,
        answer: card['term']!,
      );
      cardDocs.set(flashcard.toMap());
      flashcards.add(flashcard);
    }

    // ✅ Save to local JSON so it's readable offline after restart
    await _localStorage.saveFlashcards(deckDocs.id, flashcards);

    return newDeck;
  }

  // Get all user decks stream
  Stream<List<Deck>> getUserDecks(String userId) {
    return _firestore
        .collection('decks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Deck.fromMap(doc.id, doc.data())).toList());
  }

  // Get flashcards — tries Firestore first, falls back to local JSON
  Future<List<Flashcard>> getDeckFlashcards(String deckId) async {
    try {
      final snapshot = await _firestore
          .collection('decks')
          .doc(deckId)
          .collection('flashcards')
          .snapshots()
          .first;

      final cards = snapshot.docs
          .map((doc) => Flashcard.fromMap(doc.id, doc.data()))
          .toList();

      if (cards.isNotEmpty) {
        final localCards = await _localStorage.loadFlashcards(deckId);
        final localIds = localCards?.map((c) => c.cardId).toSet() ?? {};
        final remoteIds = cards.map((c) => c.cardId).toSet();

        if (localIds.length != remoteIds.length || !localIds.containsAll(remoteIds)) {
        await _localStorage.saveFlashcards(deckId, cards);
      }
        return cards;
      }

      // Firestore returned empty — try local JSON fallback
      print('Firestore returned 0 cards, trying local storage...');
      final localCards = await _localStorage.loadFlashcards(deckId);
      if (localCards != null && localCards.isNotEmpty) {
        print('LocalStorage: returning ${localCards.length} cards');
        return localCards;
      }

      return [];
    } catch (e) {
      print('getDeckFlashcards Firestore error: $e — trying local storage');
      // ✅ On any Firestore error, fall back to local JSON
      final localCards = await _localStorage.loadFlashcards(deckId);
      return localCards ?? [];
    }
  }

  // Delete deck — also deletes local JSON file
  Future<void> deleteDeck(String deckId) async {
    final flashcards = await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('flashcards')
        .snapshots()
        .first;

    final generatedQuiz = await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('generatedQuiz')
        .snapshots()
        .first;

    final deckBatch = _firestore.batch();
    for (final doc in flashcards.docs) {
      deckBatch.delete(doc.reference);
    }
    for (final doc in generatedQuiz.docs) {
      deckBatch.delete(doc.reference);
    }
    deckBatch.delete(_firestore.collection('decks').doc(deckId));
    await deckBatch.commit();

    // ✅ Delete local JSON file too
    await _localStorage.deleteDeckFile(deckId);
  }

  Future<void> updateDeck(String deckId, Map<String, dynamic> data) async {
    await _firestore.collection('decks').doc(deckId).update(data);
  }
}