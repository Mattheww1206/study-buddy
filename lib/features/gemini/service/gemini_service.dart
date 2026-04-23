import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  final _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash-lite');

  // Check locally without burning a request
   static const _retryKey = 'gemini_retry_after';

  Future<bool> get isAvailable async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_retryKey);
    if (saved != null) {
      final retryAfter = DateTime.parse(saved);
      if (DateTime.now().isBefore(retryAfter)) {
        print('Gemini still in cooldown until $retryAfter');
        return false;
      }
    }
    return true;
  }

  Future<void> _markQuotaHit(String errorMsg) async {
    final match = RegExp(r'retry in (\d+)').firstMatch(errorMsg);
    final seconds = int.tryParse(match?.group(1) ?? '120') ?? 120;
    final retryAfter = DateTime.now().add(Duration(seconds: seconds));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_retryKey, retryAfter.toIso8601String());
    print('Quota hit. Retry after: $retryAfter');
  }

  Future<T?> _callWithRetry<T>(Future<T> Function() fn) async {
    if (!await isAvailable) return null;
    try {
      return await fn();
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('quota') || msg.contains('429')) {
        await _markQuotaHit(msg);
      }
      return null;
    }
  }


  Future<List<List<String>>> generateDistractors({
    required List<Map<String, String>> flashcards,
  }) async {
    print('Gemini generating distractors for ${flashcards.length} cards');
    final fallback = List.generate(
      flashcards.length,
      (_) => ['None of the above', 'All of the above', 'Cannot be determined'],
    );

    final result = await _callWithRetry(() async {
      print('calling gemini for distractors');
      final formatted = flashcards
          .asMap()
          .entries
          .map((e) =>
              '${e.key + 1}. Question: ${e.value["question"]}\n   Answer: ${e.value["answer"]}')
          .join('\n\n');

      final prompt = '''You are a quiz generator. Given this Flashcard:

        $formatted  

        For each Flashcard, generate exactly 3 incorrect but plausible distractor answers.
        Rules:
        - The distractors should be related to the question but it is incorrect.
        - Do not include the correct answer in the distractors.
        - The distractors should be similar in length and complexity to the correct answer.
        - The distractors should be unique and not repetitive.
        Return ONLY a JSON array of arrays, one inner array per flashcard, nothing else.
        - Example Output: [["D1","D2","D3"],["D1","D2","D3"]]''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text!;
      print('Gemini raw response: $text');
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

      final List<dynamic> parsed = jsonDecode(cleaned);
      final distractors = parsed
          .map((inner) => (inner as List<dynamic>)
              .map((e) => e.toString())
              .take(3)
              .toList())
          .toList();

          for (int i = 0; i < flashcards.length; i++) {
          print('Card ${i + 1}: "${flashcards[i]["question"]}"');
          print('Answer: "${flashcards[i]["answer"]}"');
          print('Distractors: ${distractors[i]}');
    }
       return distractors;
    });

    if (result == null) {
    print('Gemini failed — using fallback distractors');
  } else {
    print('Gemini success — ${result.length} distractor sets generated');
  }

    return result ?? fallback;
  }

  Future<List<Map<String, String>>> generateIdentificationQuestionsBatch({
    required List<Map<String, String>> flashcards,
  }) async {
    print('Gemini generateIdentification called for ${flashcards.length} cards');
    final result = await _callWithRetry(() async {
       print('calling gemini for identification questions');
      final flashcardsJson = jsonEncode(flashcards);

      final prompt =
          '''You are a quiz generator. Convert these flashcards into identification questions.
    Flashcards: $flashcardsJson

    Rules:
    - Rephrase each question into an identification question that the user can recall.
    - Each question should be clear, concise, and end with a "?"
    - Each answer should be a short, specific word or phrase.
    - Do not give hints or include the answer in the question.
    - Return ONLY a JSON array where each object has exactly two keys: "question" and "answer".
    - The order must match the input order exactly.
    - Example Output: [{"question": "What is the capital of Philippines?", "answer": "Manila"}]''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text!;
      print('Gemini Raw response: $text'); 
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

      final List<dynamic> parsed = jsonDecode(cleaned);
      final questions = List.generate(
        parsed.length,
        (i) => {
          'question': parsed[i]['question']?.toString() ??
              flashcards[i]['question']!,
          'answer':
              parsed[i]['answer']?.toString() ?? flashcards[i]['answer']!,
        },
      );
          for (int i = 0; i < questions.length; i++) {
          print('  Card ${i + 1}:');
          print('  Original:  "${flashcards[i]["question"]}"');
          print('  Rephrased: "${questions[i]["question"]}"');
          print('  Answer:    "${questions[i]["answer"]}"');
        }

        return questions;
    });

    if (result == null) {
    print('Gemini failed — returning original flashcards as fallback');
  } else {
    print('Gemini success — ${result.length} identification questions generated');
  }


    return result ?? flashcards;
  }

  Future<List<Map<String, dynamic>>> generateTrueFalseQuestions({
  required List<Map<String, String>> flashcards,
}) async {
  print('Gemini generateTrueFalse called for ${flashcards.length} cards');

  final result = await _callWithRetry(() async {
    print('calling gemini for true/false questions');
    final flashcardsJson = jsonEncode(flashcards);

    final prompt = '''You are a quiz generator. Convert these flashcards into true or false questions.
    Flashcards: $flashcardsJson

    Rules:
    - For each flashcard, create a statement that is either TRUE or FALSE.
    - Mix the results like half should be true, half should be false or true is more than false and vice-versa.
    - For FALSE statements, make it seem like you are changing the answer to be incorrect but still plausible.
    - The statement should be clear and concise.
    - Make the question factual.
    - Return ONLY a JSON array where each object has exactly three keys: "statement", "answer".
      - "statement": the true or false question
      - "answer": either "True" or "False"
    - The order must match the input order exactly.
    - Example Output: [{"statement": "Manila is the capital of Philippines.", "answer": "True"}, {"statement": "The mitochondria is the nucleus of the cell.", "answer": "False"}]''';

        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        final text = response.text!;
        print('Gemini Raw response: $text');

        final cleaned = text
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .replaceAll('\n', '')
            .replaceAll('\r', '')
            .trim();

        final List<dynamic> parsed = jsonDecode(cleaned);
        final questions = List.generate(
          parsed.length,
          (i) => {
            'statement': parsed[i]['statement']?.toString() ?? flashcards[i]['question']!,
            'answer': parsed[i]['answer']?.toString() ?? 'True',
          },
        );

        for (int i = 0; i < questions.length; i++) {
          print('  Card ${i + 1}:');
          print('  Original:    "${flashcards[i]["question"]}"');
          print('  Statement:   "${questions[i]["statement"]}"');
          print('  Answer:      "${questions[i]["answer"]}"');
        }

        return questions;
      });

      if (result == null) {
        print('Gemini failed — returning fallback T/F questions');
        // fallback use flashcards question and answer, so answer is always true na
        return flashcards.map((f) => {
          'statement': f['question']!,
          'answer': 'True',
        }).toList();
      } else {
        print('Gemini success — ${result.length} questions generated');
      }

      return result;
    }

    Future<Map<String, dynamic>?> generateFlashcardsFromText({
      required String extractedText
    }) async {
      print('Gemini generating flashcards from uploaded file text');

      final result = await _callWithRetry(() async {

        final prompt = '''You are a flashcard generator. Given the following text extracted from the document, generate
        a set of flashcards Q&A pairs that covers the key concepts, facts, and important information.

        Text:
        """
        $extractedText 
        """

        Rules:
        - Generate as many flashcards pairs as the content warrants.
        - Each question should test understanding of a key concept from the text.
        - Each answer should be concise and clear.
        - Also determine a suitable deck title and subject based on the content.
        - return ONLY a JSON object with this exact structure, nothing else:
        {
         "title": "deck title in here",
         "subject": "subject in here",
         "flashcards": [
                      {"question": "question text", "answer": "answer text"},
                      {"question": "question text", "answer": "answer text"}      
                      ]
        }''';


        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        final text = response.text!;
        print('Gemini raw response (file): $text');

        final cleaned = text.replaceAll('```json', '')
                            .replaceAll('```', '')
                            .replaceAll('\n', ' ')
                            .replaceAll('\r', '')
                            .trim();

        final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
        print('Gemini generated ${(parsed['flashcards'] as List).length} flashcards from file');
        return parsed;
      });
      return result;
    }




}