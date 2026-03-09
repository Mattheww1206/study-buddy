import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/results/model/study_result.dart';

class ResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveResult(StudyResult result) async {
    final resultDoc = _firestore.collection('results').doc();
    await resultDoc.set(StudyResult(
      resultId: resultDoc.id,
      userId: result.userId,
      deckId: result.deckId,
      deckTitle: result.deckTitle,
      mode: result.mode,
      totalCards: result.totalCards,
      correctCount: result.correctCount,
      easyCount: result.easyCount,
      againCount: result.againCount,
      completedAt: result.completedAt,
    ).toMap());
    return resultDoc.id;
  }

  Future<List<StudyResult>> getUserResults(String userId) async {
    final snapshot = await _firestore
        .collection('results')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => StudyResult.fromMap(doc.id, doc.data()))
        .toList();
  }


}
//Future<void> saveResult(StudyResult result){}
//Future<List<StudyResult>> getUserResults(String userId){}

