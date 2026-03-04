import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class DeckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  
 

  Future<Deck> createDeck ({
    required String userId,
    required String title,
    required List<Map<String, String>> cards,

  }) async {

    final deckDocs = _firestore.collection('decks').doc();

    final newDeck = Deck(
      deckId: deckDocs.id, 
      userId: userId, 
      title: title, 
      totalCards: cards.length,
      createdAt: DateTime.now()
      );

      await deckDocs.set(newDeck.toMap());

      final cardBatch = _firestore.batch();

      for(final card in cards) {
        final cardDocs = deckDocs.collection('flashcards').doc();
        final flashcard = Flashcard(
          cardId: cardDocs.id, 
          deckId: deckDocs.id, 
          question: card['question']!, 
          answer: card['answer']!, 
          );
          cardBatch.set(cardDocs, flashcard.toMap());
      }

       await cardBatch.commit();

       return newDeck;
  }

  Stream<List<Deck>> getUserDecks(String userId){
      return _firestore
      .collection('decks')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Deck.fromMap(doc.id, doc.data())).toList());
  }

  Future<List<Flashcard>> getDeckFlashcards(String deckId) async {
    final snapshot = await _firestore 
                     .collection('decks')
                     .doc(deckId)
                     .collection('flashcards')
                     .get();
    
    return snapshot.docs.map((doc) => Flashcard.fromMap(doc.id, doc.data())).toList();
  }

   Future<void> deleteDeck(String deckId) async {

    final flashcards = await _firestore.collection('decks')
                       .doc(deckId)
                       .collection('flashcards')
                       .get();

    final deckBatch = _firestore.batch();
    for (final doc in flashcards.docs){
      deckBatch.delete(doc.reference);
    }

    deckBatch.delete(_firestore.collection('decks').doc(deckId));
    await deckBatch.commit();

   }




}

