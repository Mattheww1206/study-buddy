import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/quiz/service/quiz_service.dart';
import 'package:studybuddy/features/recentlyDeleted/service/recently_deleted_service.dart';
import 'package:studybuddy/services/local_storage_service.dart';

class FlashcardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final QuizService _quizService = QuizService();
  final RecentlyDeletedService _recentlyDeletedService = RecentlyDeletedService();

  Future<Flashcard> addFlashcard({
    required String deckId,
    required String question,
    required String answer,
  }) async {
    final cardDoc = _firestore
        .collection('decks')
        .doc(deckId)
        .collection('flashcards')
        .doc();

    final flashcard = Flashcard(
      cardId: cardDoc.id,
      deckId: deckId,
      question: question,
      answer: answer,
    );

    await cardDoc.set(flashcard.toMap());
    _firestore
        .collection('decks')
        .doc(deckId)
        .update({'totalCards': FieldValue.increment(1)});

    await _localStorage.updateInsertFlashcard(deckId, flashcard);
    _quizService.deleteGeneratedQuiz(deckId).catchError((e) => print(e));

    return flashcard;
  }

  Future<void> updateFlashcard({
    required String deckId,
    required String cardId,
    required String question,
    required String answer,
  }) async {
    _firestore
        .collection('decks')
        .doc(deckId)
        .collection('flashcards')
        .doc(cardId)
        .update({'question': question, 'answer': answer});

    await _localStorage.updateInsertFlashcard(
      deckId,
      Flashcard(
          cardId: cardId, deckId: deckId, question: question, answer: answer),
    );
    _quizService.deleteGeneratedQuiz(deckId).catchError((e) => print(e));
  }

  // ─── Delete (Offline-Aware) ──────────────────────────────────────

  /// Soft-deletes a flashcard.
  ///
  /// [isOnline] — pass `ConnectivityProvider.isConnected`.
  ///
  /// • Online  → snapshots to Firestore recentlyDeleted, then hard-deletes original.
  /// • Offline → saves to local pending queue, removes from local JSON cache
  ///             so the card disappears from the UI immediately.
  Future<void> deleteFlashcard({
    required String deckId,
    required String cardId,
    required String userId,
    required bool isOnline,
    String parentDeckTitle = '',
  }) async {
    if (isOnline) {
      await _deleteFlashcardOnline(
        deckId: deckId,
        cardId: cardId,
        userId: userId,
        parentDeckTitle: parentDeckTitle,
      );
    } else {
      await _deleteFlashcardOffline(
        deckId: deckId,
        cardId: cardId,
        userId: userId,
        parentDeckTitle: parentDeckTitle,
      );
    }
  }

  Future<void> _deleteFlashcardOnline({
    required String deckId,
    required String cardId,
    required String userId,
    required String parentDeckTitle,
  }) async {
    final cardDoc = await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('flashcards')
        .doc(cardId)
        .get();

    if (!cardDoc.exists) return;

    final flashcard = Flashcard.fromMap(cardDoc.id, cardDoc.data()!);

    await _recentlyDeletedService.softDeleteFlashcard(
      userId: userId,
      flashcard: flashcard,
      parentDeckTitle: parentDeckTitle,
    );

    await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('flashcards')
        .doc(cardId)
        .delete();

    _firestore.collection('decks').doc(deckId).update({
      'totalCards': FieldValue.increment(-1),
    });

    await _localStorage.deleteFlashcard(deckId, cardId);
    _quizService.deleteGeneratedQuiz(deckId).catchError((e) => print(e));
  }

  Future<void> _deleteFlashcardOffline({
    required String deckId,
    required String cardId,
    required String userId,
    required String parentDeckTitle,
  }) async {
    // Try to find the card in local JSON cache
    final localCards = await _localStorage.loadFlashcards(deckId) ?? [];
    final flashcard = localCards.cast<Flashcard?>().firstWhere(
          (f) => f?.cardId == cardId,
          orElse: () => null,
        );

    if (flashcard == null) {
      print('FlashcardService: card $cardId not found in local cache');
      return;
    }

    // Queue in pending deletions
    await _recentlyDeletedService.pendingDeleteFlashcard(
      userId: userId,
      flashcard: flashcard,
      parentDeckTitle: parentDeckTitle,
    );

    // Remove from local JSON so the card disappears from UI immediately
    await _localStorage.deleteFlashcard(deckId, cardId);

    print('FlashcardService: card $cardId queued for offline deletion');
  }

  /// Hard-deletes ALL flashcards in a deck (used internally during deck deletion).
  /// Does NOT create a recentlyDeleted record — the deck service handles that.
  Future<void> deleteAllFlashcards(String deckId) async {
    final snapshot = await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('flashcards')
        .snapshots()
        .first;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    await _localStorage.saveFlashcards(deckId, []);
  }
}