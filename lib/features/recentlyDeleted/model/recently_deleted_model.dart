import 'package:cloud_firestore/cloud_firestore.dart';

enum DeletedItemType { deck, flashcard }

class RecentlyDeletedItem {
  final String deletedId;       // Unique ID for this deletion record
  final String userId;
  final DeletedItemType type;
  final DateTime deletedAt;
  final DateTime expiresAt;     // deletedAt + 30 days

  // Deck fields (populated when type == deck)
  final String? deckId;
  final String? deckTitle;
  final String? deckSubject;
  final int? totalCards;

  // Flashcard fields (populated when type == flashcard)
  final String? cardId;
  final String? parentDeckId;
  final String? parentDeckTitle; // For display purposes
  final String? question;
  final String? answer;

  final bool isPendingSync;

  RecentlyDeletedItem({
    required this.deletedId,
    required this.userId,
    required this.type,
    required this.deletedAt,
    required this.expiresAt,
    this.deckId,
    this.deckTitle,
    this.deckSubject,
    this.totalCards,
    this.cardId,
    this.parentDeckId,
    this.parentDeckTitle,
    this.question,
    this.answer,
    this.isPendingSync = false,
  });

  /// Days remaining before permanent deletion
  int get daysLeft {
    final remaining = expiresAt.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Display title shown in the Recently Deleted page
  String get displayTitle {
    if (type == DeletedItemType.deck) return deckTitle ?? 'Untitled Deck';
    return question ?? 'Untitled Flashcard';
  }

  /// Display subtitle shown in the Recently Deleted page
  String get displaySubtitle {
    if (type == DeletedItemType.deck) {
      return '${totalCards ?? 0} cards • ${deckSubject ?? ''}';
    }
    return 'From: ${parentDeckTitle ?? parentDeckId ?? 'Unknown Deck'}';
  }

  Map<String, dynamic> toMap() {
    return {
      'deletedId': deletedId,
      'userId': userId,
      'type': type.name,
      'deletedAt': Timestamp.fromDate(deletedAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      // Deck fields
      'deckId': deckId,
      'deckTitle': deckTitle,
      'deckSubject': deckSubject,
      'totalCards': totalCards,
      // Flashcard fields
      'cardId': cardId,
      'parentDeckId': parentDeckId,
      'parentDeckTitle': parentDeckTitle,
      'question': question,
      'answer': answer,
    };
  }

  factory RecentlyDeletedItem.fromMap(String id, Map<String, dynamic> data) {
    return RecentlyDeletedItem(
      deletedId: id,
      userId: data['userId'] ?? '',
      type: data['type'] == 'deck'
          ? DeletedItemType.deck
          : DeletedItemType.flashcard,
      deletedAt: (data['deletedAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      deckId: data['deckId'],
      deckTitle: data['deckTitle'],
      deckSubject: data['deckSubject'],
      totalCards: data['totalCards'],
      cardId: data['cardId'],
      parentDeckId: data['parentDeckId'],
      parentDeckTitle: data['parentDeckTitle'],
      question: data['question'],
      answer: data['answer'],
    );
  }

   Map<String, dynamic> toLocalMap() {
    return {
      'deletedId': deletedId,
      'userId': userId,
      'type': type.name,
      'deletedAt': deletedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'deckId': deckId,
      'deckTitle': deckTitle,
      'deckSubject': deckSubject,
      'totalCards': totalCards,
      'cardId': cardId,
      'parentDeckId': parentDeckId,
      'parentDeckTitle': parentDeckTitle,
      'question': question,
      'answer': answer,
      'isPendingSync': true,
    };
  }

   factory RecentlyDeletedItem.fromLocalMap(Map<String, dynamic> data) {
    return RecentlyDeletedItem(
      deletedId: data['deletedId'] ?? '',
      userId: data['userId'] ?? '',
      type: data['type'] == 'deck'
          ? DeletedItemType.deck
          : DeletedItemType.flashcard,
      deletedAt: DateTime.parse(data['deletedAt']),
      expiresAt: DateTime.parse(data['expiresAt']),
      deckId: data['deckId'],
      deckTitle: data['deckTitle'],
      deckSubject: data['deckSubject'],
      totalCards: data['totalCards'],
      cardId: data['cardId'],
      parentDeckId: data['parentDeckId'],
      parentDeckTitle: data['parentDeckTitle'],
      question: data['question'],
      answer: data['answer'],
      isPendingSync: true,
    );
  }

}