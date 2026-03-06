

import 'package:cloud_firestore/cloud_firestore.dart';

class Deck {
  final String deckId;
  final String userId;
  final String title;
  final String subject;
  int totalCards;
  final DateTime createdAt;


  Deck({
    required this.deckId,
    required this.userId,
    required this.title,
    required this.subject,
    this.totalCards = 0,
    required this.createdAt,
  });

  factory Deck.fromMap(String id, Map<String, dynamic> data) {
    return Deck(
      deckId: id, 
      userId: data['userId'] ?? '', 
      title: data['title'] ?? '', 
      subject: data['subject'] ?? '',
      totalCards: data['totalCards'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'subject': subject,
      'totalCards': totalCards,
      'createdAt': createdAt,
    };
  }





}