 import 'package:cloud_firestore/cloud_firestore.dart';

class StudyResult {
  final String resultId;
  final String userId;
  final String deckId;
  final String deckTitle;
  final String mode;
  final int totalCards;
  final int correctCount;
  final int easyCount;
  final int againCount;
  final DateTime completedAt;
 

 StudyResult({
  required this.resultId,
  required this.userId,
  required this.deckId,
  required this.deckTitle,
  required this.mode,
  required this.totalCards,
  this.correctCount = 0,
  this.easyCount = 0,
  this.againCount = 0,
  required this.completedAt,
 });

 factory StudyResult.fromMap(String id, Map<String, dynamic> data){
  return StudyResult(
  resultId: id, 
  userId: data['userId'] ?? '', 
  deckId: data['deckId'] ?? '', 
  deckTitle: data['decktitle'] ?? '',  
  mode: data['mode'] ?? '', 
  totalCards: data['totalCards'] ?? 0,
  correctCount: data['totalCards'] ?? 0,
  easyCount: data['easyCount'] ?? 0,
  againCount: data['againCount'] ?? 0,
  completedAt: (data['completedAt'] as Timestamp).toDate(), 
  );
 }

 Map<String, dynamic> toMap() {
  return {
    'userId': userId,
    'deckId': deckId,
    'deckTitle': deckTitle,
    'mode': mode,
    'totalCards': totalCards,
    'correctCount': correctCount,
    'easyCount': easyCount,
    'againCount': againCount,
    'completedAt': completedAt,
  };
 }



 }