import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';


class GeminiService {
  final DeckService _deckService = DeckService();
  final _model =
      FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash-lite');

    Future<List<List<String>>> generateDistractors({
      required List<Map<String, String>> flashcards,
    }) async {
      try {
        final formatted = flashcards
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. Question: ${e.value["question"]}\n   Answer: ${e.value["answer"]}')
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

        print('Gemini raw response: $text');

        final cleaned = text
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .replaceAll('\n', '')
            .replaceAll('\r', '')
            .trim();

        // 👇 use jsonDecode instead of manual parsing
        final List<dynamic> parsed = jsonDecode(cleaned);
        final result = parsed.map((inner) => (inner as List<dynamic>).map((e) => e.toString())
        .take(3)
        .toList())
        .toList();
        print('Gemini distractors: $result');
        return result;

      } catch (e) {
        print('Gemini batch error: $e');
        return List.generate(flashcards.length, (_) => ['None of the above', 'All of the above', 'Cannot be determined']
        );
      }

    }

    Future<List<Map<String, String>>> generateIdentificationQuestionsBatch({
  required List<Map<String, String>> flashcards, // [{question, answer}, ...]
}) async {
  try {
    final flashcardsJson = jsonEncode(flashcards);

    final prompt = '''You are a quiz generator. Convert these flashcards into identification questions.
    Flashcards: $flashcardsJson

    Rules:
    - Rephrase each question into an identification question that the user can recall.
    - Each question should be clear, concise, and end with a "?"
    - Each answer should be a short, specific word or phrase.
    - Do not give hints or include the answer in the question.
    - Return ONLY a JSON array where each object has exactly two keys: "question" and "answer".
    - The order must match the input order exactly.
    - Example Output: [{"question": "What is the capital of Philippines?", "answer": "Manila"}, {"question": "Who wrote Noli Me Tangere?", "answer": "Jose Rizal"}]''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    final text = response.text!;

    print('Gemini batch iden raw: $text');

    final cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();

    final List<dynamic> parsed = jsonDecode(cleaned);

    return List.generate(parsed.length, (i) => {
      'question': parsed[i]['question']?.toString() ?? flashcards[i]['question']!,
      'answer': parsed[i]['answer']?.toString() ?? flashcards[i]['answer']!,
    });

  } catch (e) {
    print('Gemini batch iden error: $e');
    // fallback: return original flashcard data as-is
    return flashcards;
  }
}


}