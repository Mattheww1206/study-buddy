import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/gemini/service/gemini_service.dart';

class QuizService {
  final DeckService _deckService = DeckService();
  final GeminiService _geminiService = GeminiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // QUIZ GENERATORS

  // Multiple Choice Distractors
  Future<List<Map<String, dynamic>>> generateMultipleChoiceQuiz({
  required String deckId,
  required int numberOfQuestions,
}) async {
  // ✅ Check cache FIRST before loading cards
  final saved = await _getFromFirestore(deckId, 'multiple_choice');
  if (saved != null) {
    print('Firestore — MC quiz for $deckId');
    // ✅ Build directly from saved, no need for selected cards
    return _buildMCFromSaved(saved, numberOfQuestions);
  }

  // Cache miss — generate fresh
  final cards = await _deckService.getDeckFlashcards(deckId);
  cards.shuffle();
  final selected = cards.take(numberOfQuestions).toList();

  final flashcardMaps = selected
      .map((c) => {'question': c.question, 'answer': c.answer})
      .toList();

  final allDistractors =
      await _geminiService.generateDistractors(flashcards: flashcardMaps);

  await _saveMCToFirestore(deckId, selected, allDistractors);

  final freshSaved = await _getFromFirestore(deckId, 'multiple_choice');
  return _buildMCFromSaved(freshSaved!, numberOfQuestions);
}
  
  // Identification questions
  Future<List<Map<String, dynamic>>> generateIdentificationQuiz({
    required String deckId,
    required int numberOfQuestions,
  }) async {
    final saved = await _getFromFirestore(deckId, 'identification');
    if (saved != null) {
    print('Firestore — identification quiz for $deckId');
    return _buildIdenQuizData(saved.take(numberOfQuestions).toList()); // ✅
  }

    final cards = await _deckService.getDeckFlashcards(deckId);
    cards.shuffle();
    final selected = cards.take(numberOfQuestions).toList();
    
    print('Gemini generating modified questions - identification quiz for $deckId');
    final flashcardMaps = selected
        .map((c) => {'question': c.question, 'answer': c.answer})
        .toList();

    final generated = await _geminiService.generateIdentificationQuestionsBatch(
      flashcards: flashcardMaps,
    );


    await _saveIdenToFirestore(deckId, selected, generated);
    print('Firestore saved identification quiz for $deckId');

    final freshSaved = await _getFromFirestore(deckId, 'identification');
    return _buildIdenQuizData(freshSaved!);
  }

  Future<List<Map<String, dynamic>>> generateTrueFalseQuiz({
    required String deckId,
    required int numberOfQuestions,
  }) async {
    final saved = await _getFromFirestore(deckId, 'true_false');
    if (saved != null) {
      print('Firestore — T/F quiz for $deckId');
      return _buildTFQuizData(saved, numberOfQuestions);
    }

    final cards = await _deckService.getDeckFlashcards(deckId);
    cards.shuffle();
    final selected = cards.take(numberOfQuestions).toList();

    print('Gemini Generating T/F quiz for $deckId');
    final flashcardMaps = selected
        .map((c) => {'question': c.question, 'answer': c.answer})
        .toList();

    final generated = await _geminiService.generateTrueFalseQuestions(
      flashcards: flashcardMaps,
    );

    await _saveTFToFirestore(deckId, selected, generated);
    print('Firestore Saved T/F quiz for $deckId');

    final freshSaved = await _getFromFirestore(deckId, 'true_false');
    return _buildTFQuizData(freshSaved!, numberOfQuestions);
  }

  Future<List<Map<String, dynamic>>> generateRandomQuiz({
    required String deckId,
    required int numberOfQuestions,
  }) async {

    final mcData = await generateMultipleChoiceQuiz(
      deckId: deckId, 
      numberOfQuestions: numberOfQuestions
      );

    final idenData = await generateIdentificationQuiz(
      deckId: deckId, 
      numberOfQuestions: numberOfQuestions
      );

    final tfData = await generateTrueFalseQuiz(
      deckId: deckId, 
      numberOfQuestions: numberOfQuestions
      );

    final mcQuestion = mcData.map((q) => {...q, 'type': 'multiple_choice'});
    final idenQuestion = idenData.map((q) => {...q, 'type': 'identification'});
    final tfQuestion = tfData.map((q) => {...q, 'type': 'true_false'});

    final combined = [...mcQuestion, ...idenQuestion, ...tfQuestion];
    combined.shuffle();

    return combined.take(numberOfQuestions).toList();
  }



  // FIRESTORE


  // Firestore read
  Future<List<Map<String, dynamic>>?> _getFromFirestore(
      String deckId, String quizType) async {
    try {
      final doc = await _firestore
          .collection('decks')
          .doc(deckId)
          .collection('generatedQuiz')
          .doc(quizType)
          .get();

      if (!doc.exists) return null;
      return List<Map<String, dynamic>>.from(doc.data()!['questions']);
    } catch (e) {
      print('Firestore error reading quiz: $e');
      return null;
    }
  }

  

  // Firestore write
  Future<void> _saveMCToFirestore(
    String deckId,
    List<Flashcard> flashcards,
    List<List<String>> distractors,
  ) async {
    final questions = List.generate(flashcards.length, (i) => {
      'flashcardId': flashcards[i].cardId,
      'question': flashcards[i].question,
      'correctAnswer': flashcards[i].answer,
      'distractors': distractors[i],
    });

    await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('generatedQuiz')
        .doc('multiple_choice')
        .set({
      'generatedAt': FieldValue.serverTimestamp(),
      'questions': questions,
    });
  }

  Future<void> _saveIdenToFirestore(
    String deckId,
    List<Flashcard> flashcards,
    List<Map<String, String>> generated,
  ) async {
    final questions = List.generate(flashcards.length, (i) => {
      'flashcardId': flashcards[i].cardId,
      'question': generated[i]['question'] ?? flashcards[i].question,
      'answer': generated[i]['answer'] ?? flashcards[i].answer,
    });

    await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('generatedQuiz')
        .doc('identification')
        .set({
      'generatedAt': FieldValue.serverTimestamp(),
      'questions': questions,
    });
  }

  Future<void> _saveTFToFirestore(
  String deckId,
  List<Flashcard> flashcards,
  List<Map<String, dynamic>> generated,
) async {
  final questions = List.generate(flashcards.length, (i) => {
    'flashcardId': flashcards[i].cardId,
    'statement': generated[i]['statement'],
    'answer': generated[i]['answer'],
  });

  await _firestore
      .collection('decks')
      .doc(deckId)
      .collection('generatedQuiz')
      .doc('true_false')
      .set({
    'generatedAt': FieldValue.serverTimestamp(),
    'questions': questions,
  });
}


  //QUIZ DATA

  
  List<Map<String, dynamic>> _buildMCFromSaved(
  List<Map<String, dynamic>> saved,
  int numberOfQuestions,
) {
  final questions = saved.take(numberOfQuestions).toList();
  return questions.map((q) {
    final choices = [
      q['correctAnswer'].toString(),
      ...List<String>.from(q['distractors']),
    ]..shuffle();
    return {
      'flashcard': Flashcard(
        cardId: q['flashcardId'],
        deckId: '',
        question: q['question'],
        answer: q['correctAnswer'],
      ),
      'choices': choices,
      'correctAnswer': q['correctAnswer'],
      'selectedAnswer': null,
    };
  }).toList();
}

  List<Map<String, dynamic>> _buildIdenQuizData(
    List<Map<String, dynamic>> saved,
  ) {
    return saved.map((q) => {
      'question': q['question'],
      'correctAnswer': q['answer'],
      'userAnswer': '',
      'isCorrect': false,
    }).toList();
  }

  List<Map<String, dynamic>> _buildTFQuizData(
    List<Map<String, dynamic>> saved,
    int numberOfQuestions
  ) {
    return saved.take(numberOfQuestions).map((q) => {
    'flashcard': Flashcard(
      cardId: q['flashcardId'],
      deckId: '',
      question: q['statement'],
      answer: q['answer'],
    ),
    'statement': q['statement'],
    'correctAnswer': q['answer'],
    'selectedAnswer': null,
  }).toList();
}

  // Delete if deck is edited
  Future<void> deleteGeneratedQuiz(String deckId) async {
    final types = ['multiple_choice', 'identification', 'true_false'];
    for (final type in types) {
      await _firestore
          .collection('decks')
          .doc(deckId)
          .collection('generatedQuiz')
          .doc(type)
          .delete();
    }
    print('Firestore deletes generated quizzes for $deckId');
  }

  List<Map<String, String>> getWrongAnswers(
      List<Map<String, dynamic>> quizData) {
    final wrongAnswers = <Map<String, String>>[];
    for (final data in quizData) {
      final selected = data['selectedAnswer'] as String?;
      final correct = data['correctAnswer'] as String;
      final flashcard = data['flashcard'] as Flashcard;
      if (selected != null && selected != correct) {
        wrongAnswers.add({
          'question': flashcard.question,
          'correctAnswer': correct,
          'selectedAnswer': selected,
        });
      }
    }
    return wrongAnswers;
  }
  
  Future<bool> isQuizCached(String deckId, String quizType) async {
  try {
    final doc = await _firestore
        .collection('decks')
        .doc(deckId)
        .collection('generatedQuiz')
        .doc(quizType)
        .get(const GetOptions(source: Source.cache));
    return doc.exists;
  } catch (e) {
    return false;
  }
}

Future<bool> isRandomQuizCached(String deckId) async {
  try {
    final types = ['multiple_choice', 'identification', 'true_false'];
    for (final type in types) {
      final doc = await _firestore
          .collection('decks')
          .doc(deckId)
          .collection('generatedQuiz')
          .doc(type)
          .get(const GetOptions(source: Source.cache));
      if (!doc.exists) return false; 
    }
    return true; 
  } catch (e) {
    return false;
  }
}


}