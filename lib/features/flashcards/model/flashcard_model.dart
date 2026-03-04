class Flashcard {
  final String cardId;
  final String deckId;
  final String question;
  final String answer;
  
 
  Flashcard({
    required this.cardId,
    required this.deckId,
    required this.question,
    required this.answer,
  });

 factory Flashcard.fromMap(String id, Map<String, dynamic> data){
  return Flashcard(
    cardId: id, 
    deckId: data['deckId'] ?? '', 
    question: data['question'] ?? '', 
    answer: data['answer'] ?? '',
    );
 }

 Map<String, dynamic> toMap() {
  return{
    'deckId' : deckId,
    'question' : question,
    'answer' : answer,
  };
 }

}