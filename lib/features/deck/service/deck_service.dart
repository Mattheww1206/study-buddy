import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class DeckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  
 
  // create ng deck
  Future<Deck> createDeck ({
    required String userId,
    required String title,
    required String subject,
    required List<Map<String, String>> cards,

  }) async {

    final deckDocs = _firestore.collection('decks').doc();

    final newDeck = Deck(
      deckId: deckDocs.id, 
      userId: userId, 
      title: title, 
      subject: subject,
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
          question: card['def']!, 
          answer: card['term']!, 
          );
          cardBatch.set(cardDocs, flashcard.toMap());
      }

       await cardBatch.commit();

       return newDeck;
  }
  // para makuha lahat ng decks ni user for home page
  Stream<List<Deck>> getUserDecks(String userId){
      return _firestore
      .collection('decks')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Deck.fromMap(doc.id, doc.data())).toList());
  }
  // para makuha yung mga flashcards na nasa isang deck
  Future<List<Flashcard>> getDeckFlashcards(String deckId) async {
    print('Fetching from path: decks/$deckId/flashcards');
    try {
    final snapshot = await _firestore 
                     .collection('decks')
                     .doc(deckId)
                     .collection('flashcards')
                     .get(const GetOptions(source: Source.server));
    print('Snapshot docs count: ${snapshot.docs.length}');
    return snapshot.docs.map((doc) {
      print('Doc data: ${doc.data()}'); 
          return Flashcard.fromMap(doc.id, doc.data());
    })
    .toList();
    } catch (e) {
      print('getDeckFlashcards error: $e');
    rethrow;
    }

  }
   // delete ng deck
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


   Future<void> updateDeck(String deckId, Map<String, dynamic> data) async {
    await _firestore.collection('decks').doc(deckId).update(data);
   }

}

