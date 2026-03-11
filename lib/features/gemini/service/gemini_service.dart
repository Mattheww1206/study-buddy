import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  final _model =
      FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash-lite');

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
    final fallback = List.generate(
      flashcards.length,
      (_) => ['None of the above', 'All of the above', 'Cannot be determined'],
    );

    final result = await _callWithRetry(() async {
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
        - Example Output: [["D1","D2","D3"],["D1","D2","D3"]]
        ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text!;
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

      final List<dynamic> parsed = jsonDecode(cleaned);
      return parsed
          .map((inner) => (inner as List<dynamic>)
              .map((e) => e.toString())
              .take(3)
              .toList())
          .toList();
    });

    return result ?? fallback;
  }

  Future<List<Map<String, String>>> generateIdentificationQuestionsBatch({
    required List<Map<String, String>> flashcards,
  }) async {
    final result = await _callWithRetry(() async {
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
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

      final List<dynamic> parsed = jsonDecode(cleaned);
      return List.generate(
        parsed.length,
        (i) => {
          'question': parsed[i]['question']?.toString() ??
              flashcards[i]['question']!,
          'answer':
              parsed[i]['answer']?.toString() ?? flashcards[i]['answer']!,
        },
      );
    });

    return result ?? flashcards;
  }
}