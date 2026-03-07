import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyCctC-9BVL4j11PWm57Qq2GVLAyfauj0eU';

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest', 
    apiKey: _apiKey,
    );

    Future<List<String>> generateDistractors({
      required String question, 
      required String correctAnswer,
      }) async {
        try {
          final prompt = '''You are a quiz generator. Given this Flashcard:
          Question: $question
          Correct Answer: $correctAnswer
          Generate exactly 3 incorrect but plausible distractor answers.
          Rules:
          - The distractors should be related to the question but it is incorrect.
          - Do not include the correct answer in the distractors.
          - The distractors should be similar in length and complexity to the correct answer.
          - The distractors should be unique and not repetitive.
          - Return ONLY a JSON array of 3 strings, nothing else.
          - Example Output: ["Distractor 1", "Distractor 2", "Distractor 3"]
          ''';

          final content = [Content.text(prompt)];
          final response = await _model.generateContent(content);
          final text = response.text ?? '';

          final cleaned = text
                    .replaceAll('```json', '')
                    .replaceAll('```', '')
                    .trim();

          final List<dynamic> parsed = List<dynamic>.from(
            (cleaned.startsWith('['))
            ? _parseJsonArray(cleaned)
            : [],
            );

          return parsed.map((e) => e.toString()).take(3).toList();
        } catch (e) {
          // fallback distractors if gemini fails
          return ['None of the above', 'All of the above',];
        }
    }

    List<dynamic> _parseJsonArray(String json) {
      try {
        final inner = json.substring(1, json.length - 1);
        return inner.split(',').map((s) => s.trim().replaceAll('"', '')).toList();
      } catch (e) {
        return [];
      }
    }
}

