import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/recentlyDeleted/model/recently_deleted_model.dart';
import 'package:studybuddy/services/local_storage_service.dart';


class RecentlyDeletedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  static const Duration _retentionPeriod = Duration(days: 30);

  // ─── Soft Delete (Online) ────────────────────────────────────────

  Future<void> softDeleteDeck({
    required String userId,
    required Deck deck,
    required List<Flashcard> flashcards,
  }) async {
    final docRef = _firestore.collection('recentlyDeleted').doc();
    final now = DateTime.now();

    final item = RecentlyDeletedItem(
      deletedId: docRef.id,
      userId: userId,
      type: DeletedItemType.deck,
      deletedAt: now,
      expiresAt: now.add(_retentionPeriod),
      deckId: deck.deckId,
      deckTitle: deck.title,
      deckSubject: deck.subject,
      totalCards: deck.totalCards,
    );

    final batch = _firestore.batch();
    batch.set(docRef, item.toMap());
    for (final card in flashcards) {
      final cardRef = docRef.collection('flashcards').doc(card.cardId);
      batch.set(cardRef, card.toMap());
    }
    await batch.commit();
  }

  Future<void> softDeleteFlashcard({
    required String userId,
    required Flashcard flashcard,
    required String parentDeckTitle,
  }) async {
    final docRef = _firestore.collection('recentlyDeleted').doc();
    final now = DateTime.now();

    final item = RecentlyDeletedItem(
      deletedId: docRef.id,
      userId: userId,
      type: DeletedItemType.flashcard,
      deletedAt: now,
      expiresAt: now.add(_retentionPeriod),
      cardId: flashcard.cardId,
      parentDeckId: flashcard.deckId,
      parentDeckTitle: parentDeckTitle,
      question: flashcard.question,
      answer: flashcard.answer,
    );

    await docRef.set(item.toMap());
  }

  // ─── Pending Soft Delete (Offline) ──────────────────────────────

  /// Called when offline instead of softDeleteDeck.
  /// Saves the item to local pending_deletions.json so it can be synced later.
  Future<void> pendingDeleteDeck({
    required String userId,
    required Deck deck,
    required List<Flashcard> flashcards,
  }) async {
    final now = DateTime.now();
    // Generate a local ID — will be replaced by Firestore doc ID on sync
    final localId = DateTime.now().microsecondsSinceEpoch.toString();

    final item = RecentlyDeletedItem(
      deletedId: localId,
      userId: userId,
      type: DeletedItemType.deck,
      deletedAt: now,
      expiresAt: now.add(_retentionPeriod),
      deckId: deck.deckId,
      deckTitle: deck.title,
      deckSubject: deck.subject,
      totalCards: deck.totalCards,
      isPendingSync: true,
    );

    // Store the item itself
    await _localStorage.savePendingDeletion(item);

    // Store the flashcards under their own key so sync can restore them
    await _localStorage.savePendingDeckFlashcards(localId, flashcards);

    print('RecentlyDeletedService: queued offline deck deletion $localId');
  }

  /// Called when offline instead of softDeleteFlashcard.
  Future<void> pendingDeleteFlashcard({
    required String userId,
    required Flashcard flashcard,
    required String parentDeckTitle,
  }) async {
    final now = DateTime.now();
    final localId = DateTime.now().microsecondsSinceEpoch.toString();

    final item = RecentlyDeletedItem(
      deletedId: localId,
      userId: userId,
      type: DeletedItemType.flashcard,
      deletedAt: now,
      expiresAt: now.add(_retentionPeriod),
      cardId: flashcard.cardId,
      parentDeckId: flashcard.deckId,
      parentDeckTitle: parentDeckTitle,
      question: flashcard.question,
      answer: flashcard.answer,
      isPendingSync: true,
    );

    await _localStorage.savePendingDeletion(item);
    print('RecentlyDeletedService: queued offline flashcard deletion $localId');
  }

  // ─── Sync Pending Deletions ──────────────────────────────────────

  /// Flushes all locally-queued deletions to Firestore.
  /// Call this when ConnectivityProvider reports coming back online.
  Future<void> syncPendingDeletions() async {
    final pending = await _localStorage.loadPendingDeletions();
    if (pending.isEmpty) return;

    print('RecentlyDeletedService: syncing ${pending.length} pending deletions');

    for (final item in pending) {
      try {
        if (item.type == DeletedItemType.deck) {
          await _syncPendingDeck(item);
        } else {
          await _syncPendingFlashcard(item);
        }
        // Remove from local queue after successful sync
        await _localStorage.removePendingDeletion(item.deletedId);
      } catch (e) {
        // Leave in queue if sync fails — will retry next time online
        print('RecentlyDeletedService: sync failed for ${item.deletedId}: $e');
      }
    }
  }

  Future<void> _syncPendingDeck(RecentlyDeletedItem item) async {
    final docRef = _firestore.collection('recentlyDeleted').doc();

    // Load flashcards that were stored locally for this pending deck
    final flashcards =
        await _localStorage.loadPendingDeckFlashcards(item.deletedId) ?? [];

    // Write a fresh item with a real Firestore ID (replacing the local UUID)
    final syncedItem = RecentlyDeletedItem(
      deletedId: docRef.id,
      userId: item.userId,
      type: DeletedItemType.deck,
      deletedAt: item.deletedAt,
      expiresAt: item.expiresAt,
      deckId: item.deckId,
      deckTitle: item.deckTitle,
      deckSubject: item.deckSubject,
      totalCards: item.totalCards,
    );

    final batch = _firestore.batch();
    batch.set(docRef, syncedItem.toMap());
    for (final card in flashcards) {
      batch.set(docRef.collection('flashcards').doc(card.cardId), card.toMap());
    }
    await batch.commit();

    // Clean up the locally stored flashcard cache for this pending item
    await _localStorage.deletePendingDeckFlashcards(item.deletedId);
  }

  Future<void> _syncPendingFlashcard(RecentlyDeletedItem item) async {
    final docRef = _firestore.collection('recentlyDeleted').doc();

    final syncedItem = RecentlyDeletedItem(
      deletedId: docRef.id,
      userId: item.userId,
      type: DeletedItemType.flashcard,
      deletedAt: item.deletedAt,
      expiresAt: item.expiresAt,
      cardId: item.cardId,
      parentDeckId: item.parentDeckId,
      parentDeckTitle: item.parentDeckTitle,
      question: item.question,
      answer: item.answer,
    );

    await docRef.set(syncedItem.toMap());
  }

  // ─── Read ────────────────────────────────────────────────────────

  Stream<List<RecentlyDeletedItem>> getUserDeletedItems(String userId) {
    return _firestore
        .collection('recentlyDeleted')
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('expiresAt')
        .orderBy('deletedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RecentlyDeletedItem.fromMap(d.id, d.data()))
            .toList());
  }

  // ─── Restore ─────────────────────────────────────────────────────

  Future<void> restoreDeck(RecentlyDeletedItem item) async {
    assert(item.type == DeletedItemType.deck);
    assert(!item.isPendingSync,
        'Cannot restore a pending item — sync to Firestore first');

    final deletedRef =
        _firestore.collection('recentlyDeleted').doc(item.deletedId);
    final deckRef = _firestore.collection('decks').doc(item.deckId);

    final cardSnap = await deletedRef.collection('flashcards').get();

    final batch = _firestore.batch();
    batch.set(deckRef, {
      'userId': item.userId,
      'title': item.deckTitle ?? '',
      'subject': item.deckSubject ?? '',
      'totalCards': item.totalCards ?? 0,
      'createdAt': Timestamp.fromDate(item.deletedAt),
      'isPinned': false,
    });

    for (final cardDoc in cardSnap.docs) {
      batch.set(
          deckRef.collection('flashcards').doc(cardDoc.id), cardDoc.data());
    }

    batch.delete(deletedRef);
    await batch.commit();

    await _deleteSubCollection(deletedRef.collection('flashcards'));

    // ✅ Restore local JSON cache
    final restoredCards = cardSnap.docs.map((d) {
      return Flashcard(
        cardId: d.id,
        deckId: item.deckId!,
        question: d.data()['question'] ?? '',
        answer: d.data()['answer'] ?? '',
      );
    }).toList();
    await _localStorage.saveFlashcards(item.deckId!, restoredCards);
  }

  Future<void> restoreFlashcard(RecentlyDeletedItem item) async {
    assert(item.type == DeletedItemType.flashcard);
    assert(!item.isPendingSync,
        'Cannot restore a pending item — sync to Firestore first');

    final cardRef = _firestore
        .collection('decks')
        .doc(item.parentDeckId)
        .collection('flashcards')
        .doc(item.cardId);

    final batch = _firestore.batch();
    batch.set(cardRef, {
      'deckId': item.parentDeckId,
      'question': item.question ?? '',
      'answer': item.answer ?? '',
    });
    batch.update(
      _firestore.collection('decks').doc(item.parentDeckId),
      {'totalCards': FieldValue.increment(1)},
    );
    batch.delete(
        _firestore.collection('recentlyDeleted').doc(item.deletedId));

    await batch.commit();

    // ✅ Restore local JSON cache
    final restoredCard = Flashcard(
      cardId: item.cardId!,
      deckId: item.parentDeckId!,
      question: item.question ?? '',
      answer: item.answer ?? '',
    );
    await _localStorage.updateInsertFlashcard(
        item.parentDeckId!, restoredCard);
  }

  // ─── Permanent Delete ────────────────────────────────────────────

  Future<void> permanentlyDelete(RecentlyDeletedItem item) async {
    if (item.isPendingSync) {
      // Item only exists locally — just remove from the queue
      await _localStorage.removePendingDeletion(item.deletedId);
      if (item.type == DeletedItemType.deck) {
        await _localStorage.deletePendingDeckFlashcards(item.deletedId);
      }
      return;
    }

    final deletedRef =
        _firestore.collection('recentlyDeleted').doc(item.deletedId);
    if (item.type == DeletedItemType.deck) {
      await _deleteSubCollection(deletedRef.collection('flashcards'));
    }
    await deletedRef.delete();
  }

  Future<void> permanentlyDeleteAll(List<RecentlyDeletedItem> items) async {
    for (final item in items) {
      await permanentlyDelete(item);
    }
  }

  // ─── Expiry Cleanup ──────────────────────────────────────────────

  Future<void> purgeExpiredItems(String userId) async {
    final snap = await _firestore
        .collection('recentlyDeleted')
        .where('userId', isEqualTo: userId)
        .where('expiresAt',
            isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .get();

    for (final doc in snap.docs) {
      final item = RecentlyDeletedItem.fromMap(doc.id, doc.data());
      await permanentlyDelete(item);
    }

    // Also purge expired pending items from local queue
    final pending = await _localStorage.loadPendingDeletions();
    for (final item in pending.where((i) => i.isExpired)) {
      await _localStorage.removePendingDeletion(item.deletedId);
      if (item.type == DeletedItemType.deck) {
        await _localStorage.deletePendingDeckFlashcards(item.deletedId);
      }
    }
  }

  // ─── Private Helpers ─────────────────────────────────────────────

  Future<void> _deleteSubCollection(
      CollectionReference<Map<String, dynamic>> ref) async {
    final snap = await ref.get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    if (snap.docs.isNotEmpty) await batch.commit();
  }
}