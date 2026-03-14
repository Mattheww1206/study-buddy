import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/quiz/service/quiz_service.dart';
import 'package:studybuddy/services/local_storage_service.dart';

class FlashcardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final QuizService _quizService = QuizService();

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

    // ✅ Add to local JSON
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
        .update({
      'question': question,
      'answer': answer,
    });

    await _localStorage.updateInsertFlashcard(deckId,Flashcard(cardId: cardId, deckId: deckId, question: question, answer: answer),
    );
    _quizService.deleteGeneratedQuiz(deckId).catchError((e) => print(e));
  }

  Future<void> deleteFlashcard({
    required String deckId,
    required String cardId,
  }) async {
        await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('flashcards')
        .doc(cardId)
        .delete();

    _firestore.collection('decks').doc(deckId).update({
      'totalCards': FieldValue.increment(-1),
    });

    // ✅ Delete from local JSON
    await _localStorage.deleteFlashcard(deckId, cardId);
    _quizService.deleteGeneratedQuiz(deckId).catchError((e) => print(e));
  }

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

    // ✅ Clear local JSON
    await _localStorage.saveFlashcards(deckId, []);
  }
}