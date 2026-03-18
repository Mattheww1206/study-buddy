import 'package:cloud_firestore/cloud_firestore.dart';

class Deck {
  final String deckId;
  final String userId;
  final String title;
  final String subject;
  final int totalCards;
  final DateTime createdAt;
  final bool isPinned;

  Deck({
    required this.deckId,
    required this.userId,
    required this.title,
    required this.subject,
    this.totalCards = 0,
    required this.createdAt,
    this.isPinned = false,
  });

  // 1. FACTORY FOR FIRESTORE (Handles the DocumentSnapshot directly)
  factory Deck.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};
  
  return Deck(
    deckId: doc.id,
    userId: data['userId'] ?? '',
    title: data['title'] ?? '',
    subject: data['subject'] ?? '',
    totalCards: data['totalCards'] ?? 0,
    isPinned: data['isPinned'] ?? false,
    // Safely handle the timestamp for offline/online sync
    createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate() 
        : DateTime.now(),
  );
}

  // 2. UPDATED FROMMAP (Added Null-Safety for Offline/Online sync)
  factory Deck.fromMap(String id, Map<String, dynamic> data) {
    return Deck(
      deckId: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      totalCards: data['totalCards'] ?? 0,
      isPinned: data['isPinned'] ?? false,
      // CRITICAL FIX: Handle null or pending timestamps when offline
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(), 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'subject': subject,
      'totalCards': totalCards,
      // Use FieldValue.serverTimestamp() when saving to Firestore
      // but for local objects, use the createdAt DateTime.
      'createdAt': createdAt, 
      'isPinned': isPinned,
    };
  }

  Deck copyWith({
    String? deckId,
    String? userId,
    String? title,
    String? subject,
    int? totalCards,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return Deck(
      deckId: deckId ?? this.deckId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      totalCards: totalCards ?? this.totalCards,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}