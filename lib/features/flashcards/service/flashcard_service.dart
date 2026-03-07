import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class FlashcardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    answer: answer
    );

    await cardDoc.set(flashcard.toMap());

    await _firestore.collection('decks').doc(deckId).update({'totalCards': FieldValue.increment(1)});

    return flashcard;
}


Future<void> updateFlashcard({
  required String deckId,
  required String cardId,
  required String question,
  required String answer,
}) async {  

   await _firestore
         .collection('decks')
         .doc(deckId)
         .collection('flashcards')
         .doc(cardId)
         .update({
          'question': question,
          'answer' : answer,
         });
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

      await _firestore.collection('decks').doc(deckId).update({
        'totalCards': FieldValue.increment(-1),
      });
}

Future<void> deleteAllFlashcards(String deckId) async {
  final snapshot = await _firestore
                   .collection('decks')
                   .doc(deckId)
                   .collection('flashcards')
                   .get();

  final batch = _firestore.batch();
  for (final doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();
}


}


