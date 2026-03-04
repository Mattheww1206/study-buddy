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
  final int mediumCount;
  final int hardCount;
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
  this.mediumCount = 0,
  this.hardCount = 0,
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
  mediumCount: data['mediumCount'] ?? 0,
  hardCount: data['hardCount'] ?? 0,
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
    'mediumCount': mediumCount,
    'hardCount': hardCount,
    'completedAt': completedAt,
  };
 }



 }