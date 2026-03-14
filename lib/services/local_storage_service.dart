import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Gets the local file of the deck
  Future<File> _getDeckFile(String deckId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final deckDir = Directory('${appDir.path}/decks');
    if (!await deckDir.exists()) {
      await deckDir.create(recursive: true);
    }
    return File('${deckDir.path}/$deckId.json');
  }

  // Saves flashcards locally
  Future<void> saveFlashcards(String deckId, List<Flashcard> flashcards) async {
    try {
      final file = await _getDeckFile(deckId);
      final data = {
        'deckId': deckId,
        'savedAt': DateTime.now().toIso8601String(),
        'flashcards': flashcards.map((f) => {
          'cardId': f.cardId,
          'deckId': f.deckId,
          'question': f.question,
          'answer': f.answer,
        }).toList(),
      };
      await file.writeAsString(jsonEncode(data));
      print('LocalStorage: saved ${flashcards.length} cards for deck $deckId');
    } catch (e) {
      print('LocalStorage: saveFlashcards error: $e');
    }
  }

  // Load flashcards for a deck from local storage
  Future<List<Flashcard>?> loadFlashcards(String deckId) async {
    try {
      final file = await _getDeckFile(deckId);
      if (!await file.exists()) {
        print('LocalStorage: no local file for deck $deckId');
        return null;
      }
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final flashcards = (data['flashcards'] as List)
          .map((f) => Flashcard(
                cardId: f['cardId'],
                deckId: f['deckId'],
                question: f['question'],
                answer: f['answer'],
              ))
          .toList();
      print('LocalStorage: loaded ${flashcards.length} cards for deck $deckId');
      return flashcards;
    } catch (e) {
      print('LocalStorage: loadFlashcards error: $e');
      return null;
    }
  }

  // Add or update a single flashcard in local storage
  Future<void> updateInsertFlashcard(String deckId, Flashcard flashcard) async {
    try {
      final existing = await loadFlashcards(deckId) ?? [];
      final index = existing.indexWhere((f) => f.cardId == flashcard.cardId);
      if (index >= 0) {
        existing[index] = flashcard;
      } else {
        existing.add(flashcard);
      }
      await saveFlashcards(deckId, existing);
    } catch (e) {
      print('LocalStorage: upsertFlashcard error: $e');
    }
  }

  // Delete a single flashcard from local storage
  Future<void> deleteFlashcard(String deckId, String cardId) async {
    try {
      final existing = await loadFlashcards(deckId) ?? [];
      existing.removeWhere((f) => f.cardId == cardId);
      await saveFlashcards(deckId, existing);
    } catch (e) {
      print('LocalStorage: deleteFlashcard error: $e');
    }
  }

  // Delete the entire local file for a deck (when deck is deleted)
  Future<void> deleteDeckFile(String deckId) async {
    try {
      final file = await _getDeckFile(deckId);
      if (await file.exists()) {
        await file.delete();
        print('LocalStorage: deleted local file for deck $deckId');
      }
    } catch (e) {
      print('LocalStorage: deleteDeckFile error: $e');
    }
  }
}