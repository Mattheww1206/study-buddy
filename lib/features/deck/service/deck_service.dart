import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/recentlyDeleted/service/recently_deleted_service.dart';
import 'package:studybuddy/services/local_storage_service.dart';

class DeckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final RecentlyDeletedService _recentlyDeletedService = RecentlyDeletedService();

  // ─── Create ──────────────────────────────────────────────────────

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

    await _localStorage.saveFlashcards(deckDocs.id, flashcards);
    return newDeck;
  }

  // ─── Read ────────────────────────────────────────────────────────

  Stream<List<Deck>> getUserDecks(String userId) {
    return _firestore
        .collection('decks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Deck.fromMap(doc.id, doc.data())).toList());
  }

  Future<List<Flashcard>> getDeckFlashcards(String deckId) async {
    try {
      final snapshot = await _firestore
          .collection('decks')
          .doc(deckId)
          .collection('flashcards')
          .get(const GetOptions(source: Source.serverAndCache));

      final cards = snapshot.docs
          .map((doc) => Flashcard.fromMap(doc.id, doc.data()))
          .toList();

      if (cards.isNotEmpty) {
        final localCards = await _localStorage.loadFlashcards(deckId);
        final localIds = localCards?.map((c) => c.cardId).toSet() ?? {};
        final remoteIds = cards.map((c) => c.cardId).toSet();
        if (localIds.length != remoteIds.length ||
            !localIds.containsAll(remoteIds)) {
            _localStorage.saveFlashcards(deckId, cards);
        }
        return cards;
      }

      print('Firestore returned 0 cards, trying local storage...');
      final localCards = await _localStorage.loadFlashcards(deckId);
      if (localCards != null && localCards.isNotEmpty) {
        print('LocalStorage: returning ${localCards.length} cards');
        return localCards;
      }

      return [];
    } catch (e) {
      print('getDeckFlashcards error: $e — trying local storage');
      final localCards = await _localStorage.loadFlashcards(deckId);
      return localCards ?? [];
    }
  }

  Future<void> deleteDeck(
    String deckId, {
    required String userId,
    required bool isOnline,
  }) async {
    if (isOnline) {
      await _deleteDeckOnline(deckId, userId: userId);
    } else {
      await _deleteDeckOffline(deckId, userId: userId);
    }
  }

  Future<void> _deleteDeckOnline(String deckId,
      {required String userId}) async {
    final deckDoc = await _firestore.collection('decks').doc(deckId).get();
    if (!deckDoc.exists) return;

    final deck = Deck.fromMap(deckDoc.id, deckDoc.data()!);

    final flashcardSnap = await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('flashcards')
        .get();

    final flashcards = flashcardSnap.docs
        .map((d) => Flashcard.fromMap(d.id, d.data()))
        .toList();

    // Snapshot to recentlyDeleted BEFORE deleting originals
    await _recentlyDeletedService.softDeleteDeck(
      userId: userId,
      deck: deck,
      flashcards: flashcards,
    );

    // Hard-delete originals
    final generatedQuiz = await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('generatedQuiz')
        .get();

    final batch = _firestore.batch();
    for (final doc in flashcardSnap.docs) {
      batch.delete(doc.reference);
    }
    for (final doc in generatedQuiz.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_firestore.collection('decks').doc(deckId));
    await batch.commit();

    await _localStorage.deleteDeckFile(deckId);
  }

  Future<void> _deleteDeckOffline(String deckId,
      {required String userId}) async {
    // Load deck info from Firestore cache (available offline via Firestore SDK)
    final deckDoc = await _firestore.collection('decks').doc(deckId).get();
    if (!deckDoc.exists) return;

    final deck = Deck.fromMap(deckDoc.id, deckDoc.data()!);

    // Load flashcards from local JSON cache
    final localCards = await _localStorage.loadFlashcards(deckId) ?? [];

    // Queue in local pending deletions
    await _recentlyDeletedService.pendingDeleteDeck(
      userId: userId,
      deck: deck,
      flashcards: localCards,
    );

    // Remove from local cache so deck disappears from UI immediately
    await _localStorage.deleteDeckFile(deckId);

    // Note: The deck doc itself will still appear in the Firestore stream
    // until connectivity is restored and the hard-delete runs during sync.
    // To hide it immediately offline, the UI filters out pending-deleted deckIds.
    print('DeckService: deck $deckId queued for offline deletion');
  }

  // ─── Update ──────────────────────────────────────────────────────

  Future<void> updateDeck(String deckId, Map<String, dynamic> data) async {
    await _firestore.collection('decks').doc(deckId).update(data);
  }

  

  Stream<List<Deck>> getDecksStream() {
    return _firestore
        .collection('decks')
        .orderBy('createdAt', descending: true)
        // includeMetadataChanges: true makes the UI react instantly to local deletes
        .snapshots(includeMetadataChanges: true) 
        .map((snapshot) {
          return snapshot.docs.map((doc) => Deck.fromFirestore(doc)).toList();
        });
  }
}