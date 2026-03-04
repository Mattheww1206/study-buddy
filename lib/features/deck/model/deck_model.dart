import 'package:cloud_firestore/cloud_firestore.dart';

class deck {
  final String deckId;
  final String userId;
  final String title;
  int totalCards;
  final DateTime createdAt;


  deck({
    required this.deckId,
    required this.userId,
    required this.title,
    this.totalCards = 0,
    required this.createdAt,
  });

  factory deck.fromMap(String id, Map<String, dynamic> data) {
    return deck(
      deckId: id, 
      userId: data['userId'] ?? '', 
      title: data['title'] ?? '', 
      totalCards: data['totalCards'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'totalCards': totalCards,
      'createdAt': createdAt,
    };
  }





}