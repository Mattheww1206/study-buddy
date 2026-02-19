class flashCard {
  final String cardId;
  final String deckId;
  final String question;
  final String answer;
  final String? imageUrl;
  final DateTime cardCreatedAt;

  flashCard({
    required this.cardId,
    required this.deckId,
    required this.question,
    required this.answer,
    required this.imageUrl,
    required this.cardCreatedAt,
  });



}